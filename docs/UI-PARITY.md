# UI extraction and Swift bridge contract

The existing approved HTML/CSS/Canvas UI is bundled in `Sources/DreameHub/Resources/index.html`. Swift/AppKit owns the native window and WKWebView; Swift must own authentication, protocol, keychain and all API operations. This is not a SwiftUI rewrite and contains no Python runtime. The previous application's source and installed app were not changed by this extraction.

## Preserved presentation

Existing typography, colors, spacing, overview controls, station animations, map camera controls, zoom/pan, history, object-photo modal, maintenance, voice editor and preferences remain. Resources include 31 existing PNG assets used by model display. These are private-build product/brand images; their presence is not a redistribution license.

## Removed misleading presentation

- Removed the simulated field-of-view cone, its toggle, listener and legend completely.
- Removed extrapolated/interpolated robot poses. The marker uses the latest reported position without inventing movement between samples.
- Replaced the fixed "1.5 seconds" display-lag claim with source-map timestamp age. Missing timestamp displays `—`.
- Renamed LiDAR cells to map cells: these are decoded occupancy-grid values, not raw laser beams or a measured 3D point cloud.
- Wall height is explicitly visual extrusion of a 2D map, not measured height. POV remains a map viewpoint, not a camera feed.
- Removed dormant `openPlans` code; no plans/routines control is reintroduced.
- Object labels are not spoken. Photos load only through the actual device image endpoint, and failure remains visible.

## WKWebView interface

Load with base URL `dreamehub://app/` and preserve resource directory paths. The root must serve `/assets/<file>` and the audio/image endpoints below via its scheme handler. API fetch is bridged separately because WKURLSchemeHandler POST bodies can be unavailable.

`window.webkit.messageHandlers.dreameNative.postMessage({action:"theme",theme:"system"|"light"|"dark"|"liquid"})` changes native window material.

`window.webkit.messageHandlers.dreameAPI.postMessage(request)` is a reply-capable handler. Request:

```json
{"path":"/api/state","method":"GET","body":null,"contentType":"application/json"}
```

JSON uploads put decoded JSON in `body`. Binary voice upload uses `bodyBase64` instead. The reply is `{status:200,body:<JSON value>}`; optional binary reply is `{status:200,bodyBase64:"...",contentType:"..."}`. Failures use non-2xx status and `body:{error:"User-facing message"}`. Missing operations must fail honestly, never return fabricated success. Browser fallback exists only when no native API handler is present.

## API inventory

| Method | Path | Request/response |
|---|---|---|
| GET | `/api/state` | State object below |
| POST | `/api/login` | username,password,region,remember,use_saved → state |
| POST | `/api/logout` | empty object |
| POST | `/api/credentials/forget` | empty object |
| POST | `/api/device/select` | device_id; UI reloads afterward |
| POST | `/api/action` | command: start,pause,stop,dock,wash,dry_start,dry_stop,auto_empty,locate |
| POST | `/api/setting` | name,value numeric; names from HTML data-setting |
| GET | `/api/map/current` | `{map:<decoded map>}` |
| GET | `/api/cleaning/history` | `{history:[{index,date,cleaned_area}]}` |
| GET | `/api/cleaning/history/<index>/map` | `{map:<decoded map>}` |
| POST | `/api/go-to` | x,y in map/device coordinate mm |
| GET | `/api/map/obstacle/<id>/image?v=<timestamp>` | Actual binary image or failure; scheme handler |
| GET | `/api/tailscale/status` | installed,connected,enabled,url |
| POST | `/api/tailscale/enable`, `/api/tailscale/disable` | empty object → same status |
| POST | `/api/voice/install` | language |
| GET | `/api/voice/editor` | changed_count,sounds:[id,label,transcript,changed],packs:[id,name] |
| GET | `/api/voice/editor/audio/<id>?v=<timestamp>` | Binary audio; scheme handler |
| POST | `/api/voice/editor/replace?id=<id>` | Binary file; bodyBase64 |
| POST | `/api/voice/editor/reset` | id |
| POST | `/api/voice/editor/install` | empty object → changed_count |
| GET | `/api/voice/editor/transfer` | active,contacted,downloaded,bytes_sent,port |
| POST | `/api/cleaning-task` | kind,payload; dormant area-selection code, no exposed plans/routines |

## State rendering keys

Top-level: `authenticated`, `warning`, `boot:{busy,stage,error}`, `credentials:{username,region,available,remembered}`, `devices:[{id,name,selected}]`, `tailscale:{installed,connected,enabled,url}`, `device`.

Device text/state: `name`, `model`, `image_url`, `state_text`, `battery`, `cleaned_area`, `cleaning_time`, `cleaning_progress`, `base_status_text`, `drying_progress`, `updated_at`, `voice_status_text`, `voice_language`.

Device capability flags: `supports:{go_to,cleaning_mode,suction,water,base,auto_empty,map,voice}` and `sensor_profile:{lidar,camera,laser_obstacle,obstacles}`. Capability flags describe support, not a live measurement.

`dock_health` keys clean_water,dirty_water,detergent,dust_bag each use `{value,text,attention}`. `consumables` keys main_brush,side_brush,filter,sensor are hours reported by device, not percentages. Missing data must be null/absent, never invented. `controls` keys suction,washing,hot_wash,auto_wash use `{value,available,reason,options:[{value,label,available}]}`. HTML setting controls also read matching keys on device.

Map shape: `size:[left,top,width,height,pixelWidth,pixelHeight,gridMM]`; `data:{cellType:[x,y,runLength,...]}`; `robot_position:[x,y,heading]`; `charger_position:[x,y,heading]`; `path:[type,x,y,...][]`; `segments`; `obstacles`; `laser_obstacles`; `cliffs`; `frame_id`; `timestamp_ms`; `telemetry:{observed_at,metrics:{path_points,occupancy_cells}}`; optional `alerts`, `cleaned_area`, `cleaning_time`. Do not synthesize detections for missing sensor streams.

## Verification boundary

Extraction and JavaScript syntax validation passed. Targeted JavaScript execution also passed native JSON request/reply, non-2xx error propagation, binary voice upload and exact reported pose checks; forbidden simulated cone/extrapolation/routine code is absent. This document does not claim Swift backend parity or real-device integration success. Those need separate build, UI and actual account/device checks by the main implementation.
