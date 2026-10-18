# Dreame Hub Swift migration — implementation and verification status

## Contract
- Preserve the installed application's design and working features. Do not replace it before parity is verified.
- No Python runtime or Python service in the Swift application.
- Preserve the current HTML/CSS/canvas presentation inside Apple's WKWebView; native lifecycle, credential storage and networking in Swift/AppKit.
- No fabricated sensor measurements, field-of-view cones, proximity arcs, or fake live feeds.
- Distinguish decoded device map observations from raw sensor data and measured 3D geometry.
- Correct stale README claims: point navigation is user-confirmed working in the existing app; removed routines are not a missing advertised feature.

## Work ownership
- Root: native application, secure bridge, state/control integration, parity tests, packaging, documentation corrections.
- swift_cloud: Swift cloud authentication and RPC transport.
- swift_map: map decoder and telemetry evidence audit.
- swift_ui: preserved UI resources, removal of illustrative sensor visuals.

## Acceptance gates
1. Clean Swift build and unit tests without Python dependency.
2. Existing and Swift UI parity check (summary, map, maintenance, sounds, preferences).
3. Read-only real account/device verification: authentication, discovery, status, map and observation provenance.
4. Explicitly recorded live control/voice/Tailscale checks; no unrequested physical operations during development.
5. Installed version only replaced once feature parity and verification gates pass.

## Current status
Swift implementation is packaged independently of the installed legacy app. Native authentication, status, current/history maps and actual obstacle JPEG retrieval passed read-only integration. The preserved WKWebView design remains; Python is not bundled or launched. Physical behavior is deliberately not certified. See docs/VERIFICATION.md for exact tests, UI results and known narrower model/decoder coverage. This is a preview with a verified read-only path, not an all-model or physically validated replacement claim.
