# Telemetry provenance audit — Swift migration

Audit date: 15 October 2026. This document distinguishes protocol code evidence from successful live-device observation. A declared model capability is not proof that the firmware exports its raw sensor measurements.

## What the existing app actually received

The previous app used the Dreame account/cloud protocol and Tasshack's map parser. `DreameClient.map_current()` obtained `status.current_map`, passed it through `get_map_for_render()`, and serialized the renderer output. It did not subscribe to a raw LiDAR point-cloud, camera-frame, or time-of-flight distance stream. The earlier artificial front FOV was a rendering effect, not a sensor measurement.

| Data | Actual source | Meaning and limitations |
| --- | --- | --- |
| Occupancy / room grid | 27-byte binary map header + width × height bytes | Robot-generated 2D map cells. Geometry can be displayed in a 3D perspective, but cell extrusion is not measured height or a 3D LiDAR cloud. |
| Robot position / orientation | Signed little-endian x/y/angle at header offsets 5/7/9 | Reported localization pose at the map frame's time. Do not extrapolate movement when data stops. |
| Dock pose | Header offsets 11/13/15 | Reported map entity, not a measured dock model. 32767 sentinel / `nc` indicates absence. |
| Route | Metadata `tr`, operators M/W/S/L/l | Recorded route coordinates, not future planned navigation or obstacle avoidance rays. `L` is relative; lowercase `l` is absolute continuation. |
| AI object detections | `ai_obstacle` records | Position, category, confidence and optional object/photo identifiers reported by the robot. No replacement photo, confidence or image may be invented. Detection timestamp is usually map-level, not per-object. |
| Laser obstacle records | `laser_obstacle` | Processed obstacle coordinates/category; **not laser scan rays**. A missing confidence field is unknown, not 100%. |
| Cliff lines | `vws.cliff` | Map-level cliff annotations within the virtual-threshold structure. They are not raw downward-sensor readings or live distances. May include persistent map configuration. |
| Virtual walls/no-go/no-mop | `vw.line` / `vw.rect` / `vw.mop` | Persistent map constraints, not sensor discoveries. |
| Room metadata | `seg_inf` | Robot map metadata. Room label placement computed from cell geometry is a layout decision, not another sensor. |
| Cleaned area/time/work state/battery | `cs` / `ct` / `wm` / `clean_finish_remain_electricity` when present | Reported map metadata. Do not infer missing values. Battery in a historical map is historical. |
| Map update identity | map ID, frame ID, `timestamp_ms` | Used for freshness and ordering. Receipt time is separate from capture time; absent timestamp remains unknown. |
| Sensor maintenance remaining | MIOT consumable properties if supported | Service-life counter, **not a live sensor feed or sensor health measurement**. |

Source evidence in the previous implementation: `dreame/map.py` around lines 4202–4272 (envelope), 4309–4463 (header/pose/path), 4540–4770 (grid/rooms), 5147–5267 (AI/laser), 5330–5361 (virtual walls/cliffs), 5770–6030 (incremental frames). `app.py` around lines 884–939 shows the original serialized telemetry. These are repository source observations, not vendor API guarantees.

## How updates reach the app

The original map manager reads cloud property histories for MAP_DATA and OBJECT_NAME. MAP_DATA can contain short incremental packets; OBJECT_NAME identifies a signed downloadable map object. Streaming push/MQTT and full-frame polling have different latency. Reading a current cloud property once does not establish a live stream. A stored map can remain unchanged while the device is idle.

The transport envelope is URL-safe base64; optionally a comma-delimited key. Encrypted payloads use AES-CBC, with the first 32 ASCII hex characters of SHA-256(key) as the AES key, plus a model-specific 16-byte IV. The decrypted bytes are zlib compressed. An unavailable IV is an explicit failure, not permission to substitute a map. Full `I` (73) frames and delta `P` (80) frames are different. Legacy P bytes are added modulo 256 to the previous frame, while v3 P bytes replace nonzero cells. A delta with missing predecessor cannot safely be shown as a complete map.

`MapService` now reads OBJECT_NAME as the protocol's string key `6.3` (not an array), fetches its signed object, and polls MAP_DATA `6.1` history after the accepted timestamp. It retains full-frame state and applies consecutive legacy frame-map and v3 P frames. A sequence gap does not become fabricated movement: it attempts a full-map refresh and exposes a warning. Poll time never overwrites capture time. This is cloud polling, not a verified low-latency MQTT feed.

## Raw signals not established by this audit

No authenticated implementation path was found in the currently used map protocol for raw LiDAR rays/ranges, scanning frequency, depth/point clouds, front/side/rear/bottom distance readings, RGB camera frames, optical-flow frames, or a sensor-aligned measured field-of-view boundary. Firmware may use these signals internally; that does not make them exported to this client. Models with a separate remote-camera feature require a separately verified protocol, account consent and model support. This migration does not claim to implement that feature.

Obstacle photo retrieval is separate from the map. An object ID is only a lookup key. Upload settings, retention, firmware and model can make its photo unavailable. Capability flags must not be presented as a successfully downloaded photo. Native `ObstaclePhotoService` implements cloud-object AES-ECB and local-storage AES-CBC. The latter queries the device's photo key using an ephemeral RSA public key (SIID 14/AIID 1/PIID 5), decrypts RSA-OAEP-SHA1 in Security, and never persists the private key. These are retrieval/decryption operations, not camera-control or recording commands. The local-storage branch has synthetic cryptographic tests but no successful real-device photo retrieval evidence yet.

## Native decoder implemented in this migration

`Sources/DreameCore/MapDecoder.swift` uses Foundation, CryptoKit, CommonCrypto and system zlib. It does not launch or embed Python. It validates envelope/header/dimensions/JSON, bounds decompressed output to 32 MiB, decodes full I-frame grids for map versions 0–3, poses, routes, object/laser records, cliff and virtual-wall lines and basic room metadata. Output uses the existing renderer's JSON field shapes. It emits `simulated: []` and explicitly disables raw-ray/vision/proximity capabilities. Missing capture timestamps and missing laser confidence remain unknown.

### Remaining parity gates — do not mark completed

- Stateless decoding intentionally rejects P frames without a predecessor. `MapStreamDecoder` implements consecutive legacy frame-map P accumulation (modulo-256 cell addition, expanded grid offsets, pose and path updates), plus v3 nonzero pixel replacement, `cover` timestamp/path/laser metadata, and `diff.ai_obstacle` upserts/deletions keyed by the reported stable index. A legacy predecessor without `fsm=1` still requires a different retained-pixel-type transition and is rejected; the tested device's predecessor has `fsm=1`. Missing frames remain rejected. Full-map reacquisition is implemented, but recovery after real packet loss while moving is not verified.
- Nested `rism` decoding now preserves saved-map room metadata and dock fallback, and composes the saved grid with cleaning cells according to the original status-2/restored/recovery branch. Recursion, bounds and grid sizes are validated. A synthetic saved-map/cleaning-layer fixture was compared to the original decoder's combined grid and matched exactly. Alternate map-version-zero optimization and unusual floor variants still need device fixtures.
- Complex furniture, carpet polygons, curtains, saved-floor selection and every metadata variant have not been ported to this decoder.
- A private encrypted current-device full-frame capture was decoded in native Swift and compared to the original Python decoder. Grid RLE, size/crop, robot pose, dock pose, frame/map identifiers, laser and cliff arrays matched exactly. Empty path/object collections differed only as `null` versus `[]`. The captured frame contained nested `rism`, but its `fsm` geometry was self-contained and matched without nested composition. This does not prove parity for frames which depend on nested composition.
- Real motion freshness, obstacle photo access and feature-by-feature visual parity require live verification. No physical movement command was sent by this audit.

## Required truthful UI behavior

Show only received pose/path/map records. Do not draw a rotating radar sweep, artificial cone, inferred parking-sensor arcs, fake laser beams, interpolated obstacle positions or random points. Keep grid/3D perspective labeling distinct from raw sensor telemetry. Show delayed/unknown timestamp state rather than treating receipt time as observation time. Historical maps must say they are historical. An unavailable layer is absent/unknown, not a measured zero. All source paths must retain actual server error states; do not fall back to synthetic demo data after a real login.

## Verification status

- Swift package build and eight permanent `MapDecoderTests`: passed locally. Tests cover full grid/pose/path, no artificial sensor measurements, unknown timestamp/confidence, malformed-frame rejection, ordered legacy delta addition, dropped-predecessor rejection, registry lookup, nested grid composition, and v3 cover/object upsert/delete behavior.
- Independent synthetic v3 differential comparison with the original decoder matched grid/size, pose, route, IDs, laser/cliff records and object fields 0–11 (identity, coordinates, category, confidence, ignore/photo status, photo ID and image bounds). Derived object room-name/color association is not yet identical to the old renderer; it is not a sensor measurement. The comparison deliberately does not label this secondary metadata as exact parity.
- Additional deterministic development fixtures passed zlib/base64, SHA256/AES-CBC envelope, missing-IV rejection and version-3 grid/carpet decoding.
- Two permanent `ObstaclePhotoTests` passed: image-format rejection and Security SPKI public-key import / RSA-OAEP-SHA1 encryption-decryption roundtrip.
- Current-device native login + full-map download/decrypt/parse: verified read-only by the integration agent. Exact raw-grid differential comparison independently passed, as described above. The private fixture remains outside the repository and is not distributed.
- Cleaning history list: integration agent observed 30 records. Archived map 1 decoded with one object detection. This verifies that historical detection retrieval works, not that a photo exists.
- Native historical obstacle photo retrieval subsequently succeeded: integration agent received 132,965 bytes with JPEG signature from that detection. This supersedes the earlier missing-photo observation for this particular record. It proves retrieval/decryption for the tested record, not universal photo availability. Visual inspection of the actual modal is a separate UI gate. No private photo is bundled in the repository.
- The docked robot's map was approximately 3,419 seconds old at the integration check. This is a successful stale-map read, **not a live-refresh or moving-robot test**. UI must preserve that distinction.
- Moving-robot refresh/ordering test: not verified.

## Navigation documentation correction

Target navigation must not be called broken or experimental merely because an earlier attempt failed; the user confirmed it works in the established app. Conversely, porting command code does not prove the new native build has physically reached a target. The current migration's physical navigation test is deliberately pending because verification is read-only. Upstream distinguishes native cruising from a controlled zone-cleaning fallback, which requires stopping and restoring settings at arrival. [Upstream vacuum services](https://dv.tasshack.com/guide/services/vacuum-services#go-to-point), checked 15 October 2026. Following a historical drawn route and sending a point-navigation command are different behaviors; neither implies access to raw sensor streams.

This is a bounded migration implementation and evidence inventory, not a claim that the entire Swift app is ready for replacement.
