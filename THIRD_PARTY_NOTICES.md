# Third-party notices

The Dreame protocol and map interoperability algorithms are translated from the bundled Tasshack/dreame-vacuum implementation. Its MIT license notice is retained in `licenses/dreame-vacuum-LICENSE`.

The optional native audio codec is libsndfile, not a Python runtime. Neither the source repository nor the public DMG distributes its binary. The LGPL-2.1 text is retained for reference; independently installed libraries retain their licenses. Any future distribution bundling the codec requires exact source/relinking information and embedded-codec notices.

Starting with v0.2.3, MOVA product images in `Sources/DreameHub/Resources/assets/products/mova/` are third-party manufacturer artwork, sourced from the official MOVA product site. The directory's `SOURCES.json` records original URLs and attribution. There are 21 transparent PNGs for 22 model families; E40's transparent source WebP was converted losslessly to PNG. No AI-generated product substitutes are used.

These images and associated trademarks are **excluded from the source code's MIT license** and remain the property of their respective rights holders. Their inclusion does not assert a redistribution license, endorsement or trademark rights. Do not assume the MIT license grants rights to independently extract, redistribute or reuse this artwork. The neutral fallback SVG is an original project asset. Unknown models retain that fallback; product colors are representative, not measured from device data.

The official Dreame app icon remains excluded from the public application's resources; macOS supplies the default application icon. Promotional screenshots and videos show the privately configured application; they do not grant rights to extract or reuse third-party artwork.

Apple frameworks (AppKit, WebKit, Foundation, Security, CryptoKit), system CommonCrypto and zlib are used from macOS. This project is independent and is not endorsed by Dreame, MOVA or Apple.
