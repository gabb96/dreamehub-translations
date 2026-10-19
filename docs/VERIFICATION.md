# Swift migration verification ledger

Updated: 2026-10-19. This is an evidence ledger, not an all-features completion certificate. The existing installed Python application is unchanged. Normal Swift launch is control-capable; every migration test and UI inspection used `--read-only` or `--verify-readonly`. No physical operation is authorized by this document.

## MOVA v0.2.2 preview — 2026-10-19

- Explicit provider selection routes MOVA credentials to the MOVA service, using provider-specific tenant, app identity, signing and refresh context. No automatic cross-provider credential fallback is used.
- Offline tests cover MOVA routing/signing/refresh, legacy credential decoding, saved-account mismatch rejection and exact model recognition. These are synthetic transport tests, not live login evidence.
- Catalog: 22 families / 84 exact IDs. Grouped cleaning encoding: 78 audited IDs plus a live self-wash-base property guard. Catalog entries do not unlock target navigation.
- Compact login layout was inspected at 720 × 540 without authenticating; the provider selector and connect button fit. Native panel lifecycle checks do not make any cloud/device requests.
- **No real MOVA account or device validation has occurred. Authentication, maps, photos, physical commands and voice installation remain unverified on MOVA. No movement command was sent for this update.**
- Public builds exclude manufacturer PNGs without verified redistribution permission and use neutral artwork. Private-build image checks are not evidence that those images ship in the public DMG.
- Earlier Dreame evidence below remains specific to the named Dreame device. Versioned test totals below are historical, not v0.2.2 release totals.

**Türkçe:** MOVA entegrasyonu gerçek hesap veya robotla doğrulanmadı. Giriş, harita, fotoğraf, fiziksel komut ve ses kurulumu doğrulama bekliyor. Bu sürümün çevrimdışı testleri, mevcut Dreame cihazındaki önceki okuma kanıtının MOVA'ya uygulanabileceği anlamına gelmez. MOVA hedefe gitme açık değildir; bu güncellemede hareket komutu gönderilmedi. [Ayrıntılar](MOVA.md).

## Observed evidence

| Check | Evidence and boundary |
|---|---|
| Native authentication/properties | Main integration run reports native login, selected L10s Pro Ultra Heat and 25 property values. No Python runtime used. This establishes reads, not successful control writes. |
| Current map | Main integration and map agent report actual encrypted full-frame retrieval/decode. Geometry, size, robot/dock pose, frame/map identities, laser and cliff arrays matched the original decoder on the same private input. The docked map was stale; this is not a moving-robot freshness test. |
| History | Main integration read 30 records and decoded the latest archived map. |
| Object photo | Earlier run retrieved a real historical JPEG, 132,965 bytes; the actual shoe photo was visibly opened in the native modal. On October 18 the latest history map contained 5 detections and a real 140,312-byte JPEG was retrieved. Availability on every marker/model is not established. |
| UI bridge | Executed JavaScript bridge tests passed JSON request/reply, non-2xx error propagation and binary upload. These are focused integration-boundary tests, not full UI acceptance. |
| Map presentation | `node Tests/JS/MapPresentationTests.js` passed. Executes shipped Canvas drawing and checks robot/dock +90° clockwise presentation, unchanged device coordinates, no extrapolation, finite rendering in 2D/3D/Clay/POV at three viewport sizes, removed sensor cone and routine code. Mock Canvas does not prove visual quality. |
| Native voice | Real official manifest/hash/archive yielded 257 sounds. Original OGG preview was 24,055 bytes; Swift mono/resampling plus native Vorbis encoding produced a 4,602,708-byte custom archive containing one changed entry. No Python/ffmpeg dependency and no installation on the robot. |
| Voice transport | Native localhost listener returned exact package bytes, supported HTTP 206 ranges and rejected a wrong token path with 404. This is not a robot LAN transfer test. |
| Voice tests | Six `VoiceServiceTests` pass in the final integrated suite. The earlier intermediate compile failure is superseded by the final 42-test passing run. The UI now shows the Turkish announcement labels, a valid language selection and playable 6-second local preview. No robot audio installation was attempted. |
| Native UI inspection | Overview, map zoom/center, archived map selection, actual object-photo modal, maintenance, voice catalog and preferences inspected in native WKWebView. Dark and liquid material visibly differ. Loading presents a progress message, not an empty screen. One connected robot was available; multi-device switching remains unverified on real hardware. |

Tests use synthetic fixtures for protocol edge cases where stated. Private home map fixtures, photos, credentials and logs must not be committed or distributed.

## Bounded-motion and refresh update — 2026-10-18

- `swift test`: 51 tests, zero failures, including nine new offline map-acquisition tests.
- `RobotMotionTests.js`: bounded transitions (maximum 900 ms), shortest heading, duplicate/conflicting/old observations, stale data, history/map switches, reduced motion and zero extrapolation passed.
- `MapRefreshTests.js`: ten offline cases against the actual UI functions passed. Late responses cannot replace a newly selected source; errors retain the last map; conflicting cached geometry is ignored while freshness/warnings update.
- `MapPresentationTests.js`: actual renderer executed in four views at three sizes; no coordinate mutation or simulated sensor cone.
- Initial instant-jump behavior was reproduced with a failing midpoint assertion. A history-to-current regression introduced during the fix was also reproduced before correction.
- Native read-only launch visibly restored the saved session and displayed the actual map with its stale timestamp, heading and recorded detections. No physical robot command was sent. Moving-device update latency remains unverified.
- This source update is not evidence that an older DMG contains it. Packaging and the sanitized public source build are separate checks.

## Final integrated gates

- [x] October 18 final `swift test`: 42 tests, zero failures.
- [x] JavaScript renderer regression suite passed against the source bundled by the build, including +90° dock/robot orientation, unchanged target coordinates and no pose extrapolation.
- [x] Optimized ARM64 app built and ad-hoc signature verified. Bundle contains no Python executable, framework, .py or .pyc. Networking/decoding/credentials/control implementation is Swift; approved HTML/CSS/Canvas remains in WKWebView. Native audio uses a bundled C codec.
- [x] Native UI flows listed above inspected in read-only mode. Physical controls visibly disabled and rejected by the API. One robot only: no real multi-device/account-switch acceptance claim.
- [x] Native `--verify-panel` harness passed status-button open/close and optional-window-to-popover return using the actual AppKit objects, with no cloud/device calls. This is a programmatic lifecycle test, not a claim of a manually clicked status icon.
- [x] Quit/relaunch through the native app succeeded with no remaining test process after quit. October 18 relaunch screenshot confirmed the selected dark theme persisted and the account signed in automatically.

Do not tick a gate from compilation alone. Record the exact result or a concrete remaining defect; a failed intermediate check must not be silently represented as passed.

## Deliberately unverified physical operations

Point navigation is owner-confirmed working in the previous application. The Swift command, arrival-stop and setting-restoration paths are implemented but not physically exercised here. Start/pause/stop/dock, washing/drying/emptying, settings writes, actual voice installation, robot-side package download and remote Tailscale access are likewise not live-tested. Read-only tests cannot establish their parity. The removed plans/routines interface is not a pending feature and must not be reintroduced as a gap.

## Remaining data and release limits

- Cloud polling is implemented; MQTT push and moving-robot latency/recovery remain unverified.
- Native cruising-model navigation is not ported; the supported grouped-family target implementation is separate and physically unverified. Full upstream per-model/state availability predicates are not all ported. Do not claim universal parity.
- Raw LiDAR ranges/point clouds, live vision/depth frames and side/rear/downward proximity readings have no established export path through this connection. No simulated replacement is shown.
- Legacy non-frame-map P-frame transitions and uncommon metadata/floor variants require additional real fixtures. Complex furniture/carpet/curtain data and saved-floor selection are not complete decoder parity. See [telemetry audit](TELEMETRY-AUDIT.md).
- 3D walls and robot/dock shapes are presentation of real 2D positions, not measured 3D geometry. POV is not a camera feed.
- Native codec/product-artwork redistribution rights, source notices, signing/notarization and broader model compatibility require separate release review.
- Existing launch ZIPs, DMG and videos are legacy Python-era artifacts. Correcting their adjacent Markdown does not rewrite their archived contents or make them Swift evidence.

## v0.2.3 product artwork checks — 2026-10-19

63 Swift tests and three JavaScript regression suites passed. All 21 PNGs decode with transparency, map to the 22 catalog families and are reachable through the application presentation path. Unknown models retain the neutral fallback. The actual interface was checked at 720×540 with an offline MOVA V50 fixture: its 896×897 PNG loaded in the 76×76 device header without clipping. This fixture does not establish live MOVA account/device compatibility. Manufacturer artwork is included with source attribution and is excluded from the code's MIT license; the v0.2.2 artwork exclusion below is historical.

## v0.2.2 public release checks — 2026-10-19

61 Swift tests passed (0 failures), plus MapPresentationTests.js, MapRefreshTests.js and RobotMotionTests.js. These are offline regression tests, not MOVA account/device validation. Manufacturer PNGs and the private codec binary are excluded from the public package; neutral original SVG artwork is included. Older private-build observations above are historical and do not describe bundled public-release assets.
