/* Presentation only: interpolate received observations, never predict a future pose. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.DreameRobotMotion = factory();
})(typeof globalThis === 'object' ? globalThis : this, function () {
  'use strict';
  const MAX_TWEEN_MS = 900, MAX_GAP_MS = 6000, MAX_JUMP_MM = 2000;
  const wrap = angle => ((angle % 360) + 360) % 360;
  function create() {
    let latest = null, segment = null;
    function reset() { latest = null; segment = null; }
    function freeze() { segment = null; }
    function pose(now) {
      if (!latest) return null;
      if (!segment) return latest.pose.slice();
      const t = Math.max(0, Math.min(1, (now - segment.start) / segment.duration));
      if (t >= 1) { segment = null; return latest.pose.slice(); }
      const eased = t * t * (3 - 2 * t), a = segment.from, b = latest.pose;
      const angle = ((b[2] - a[2] + 540) % 360) - 180;
      return [a[0] + (b[0] - a[0]) * eased, a[1] + (b[1] - a[1]) * eased, wrap(a[2] + angle * eased)];
    }
    function sample(map, receivedAt, wallNow = Date.now(), reducedMotion = false) {
      const raw = map && map.robot_position;
      if (!Array.isArray(raw) || raw.length < 3 || !raw.slice(0, 3).every(v => typeof v === 'number' && Number.isFinite(v))) {
        reset(); return false;
      }
      const next = {pose: [raw[0], raw[1], wrap(raw[2])], time: Number(map.timestamp_ms),
        mapID: String(map.map_id ?? ''), frame: Number(map.frame_id), receivedAt};
      const history = map.history_map === true;
      if (latest && next.mapID === latest.mapID && !history) {
        if (Number.isFinite(next.time) && Number.isFinite(latest.time) && next.time < latest.time) return false;
        if (next.time === latest.time && Number.isFinite(next.frame) && Number.isFinite(latest.frame)) {
          const distance = ((next.frame - latest.frame) % 65536 + 65536) % 65536;
          if (distance === 0 || distance >= 32768) return false;
        }
        // Duplicate polling cannot restart or extend a transition.
        if (next.pose.every((v, i) => v === latest.pose[i])) {
          if (next.time >= latest.time) { latest.time = next.time; latest.frame = next.frame; }
          return false;
        }
      }
      const previous = latest;
      const from = pose(receivedAt);
      const gap = previous ? receivedAt - previous.receivedAt : Infinity;
      const sourceGap = previous ? next.time - previous.time : Infinity;
      const fresh = Number.isFinite(next.time) && wallNow - next.time >= -2000 && wallNow - next.time <= MAX_GAP_MS;
      const close = previous && Math.hypot(next.pose[0] - previous.pose[0], next.pose[1] - previous.pose[1]) <= MAX_JUMP_MM;
      latest = next;
      const eligible = previous && from && next.mapID === previous.mapID && !history && !reducedMotion && fresh && close &&
        gap > 0 && gap <= MAX_GAP_MS && sourceGap > 0 && sourceGap <= MAX_GAP_MS;
      segment = eligible ? {from, start: receivedAt, duration: Math.min(MAX_TWEEN_MS, Math.max(120, gap * .8))} : null;
      return true;
    }
    return {sample, pose, reset, freeze};
  }
  return {create, MAX_TWEEN_MS};
});
