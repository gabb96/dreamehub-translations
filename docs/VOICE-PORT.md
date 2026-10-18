# Native Swift voice service validation

`DreameCore/VoiceService.swift` fetches the model-specific official manifest, downloads and MD5-checks its Turkish archive, parses root-only USTAR safely, lists/plays original announcements, converts replacements to mono 16 kHz Vorbis, resets edits and constructs the root-flat custom tar.gz. `VoiceTransferHost.swift` serves one package from the Mac's robot-facing interface, restricted to the known robot IPv4 and a random token URL, for at most 15 minutes. It supports GET/HEAD and single byte ranges. A completed download is not proof of successful installation.

No Python interpreter, Python subprocess, package or Python bridge is used. Decoding and Vorbis encoding call the native libsndfile C ABI directly. Mono mixing, resampling and peak limiting are Swift. System gzip compresses/decompresses the tar container. The existing C library was copied to `Resources/native` with LGPL-2.1 license text; it depends only on system libSystem on this arm64 Mac. This does not make the app Universal or remove redistribution/source-notice requirements. No ffmpeg dependency or hidden automatic installation is required.

Integration: instantiate `VoiceService(model:labelsURL:vorbisLibraryURL:)`, pointing labels to `Resources/voice_labels_tr.json` and codec to `Resources/native/libsndfile_arm64.dylib`. Recreate on device/model switch to isolate edits. For official install use `pack(language:).installValue`, serialize to a JSON string and send the existing cloud property (siid 7, piid 4). For custom install call `build()`, `VoiceTransferHost(payload:peerIP:)`, await `start()`, then send id CUSTOM/url/md5/size using the same property. Close host if command fails or device changes. Never retry a device install automatically after an ambiguous response.

Verified during migration, 2026-10-15:

- Compiled both native files using Swift.
- Real official model `dreame.vacuum.r2338a` manifest + verified package produced 257 sound entries.
- Original announcement 0 preview: 24,055 bytes.
- Converted that original recording through native libsndfile decode, Swift mono/resampling and 16 kHz mono Vorbis encode; built 4,602,708-byte custom tar.gz with exactly one changed entry, without ffmpeg.
- Native localhost test served exact bytes, HTTP 206 range bytes, and rejected an incorrect token path with 404.
- Root-only tar roundtrip and traversal rejection passed; regression tests were added.

No voice package was installed on the physical vacuum. LAN transfer to the actual robot, device acceptance and audible playback have not been verified in this migration. Local codec and HTTP tests do not imply those have passed.
