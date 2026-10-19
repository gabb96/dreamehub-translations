# MOVA Home — preview / önizleme

[English README](../README.md) · [Türkçe README](../README.tr.md) · [Model catalog / Model kataloğu](SUPPORTED-MODELS.md)

## English

v0.2.2 adds an explicit **Dreame Home / MOVA Home** account selector while retaining the existing menu-bar interface. Choose the service where your robot is registered, then that account's server region. A MOVA-branded robot registered in Dreame Home still uses the Dreame Home option. Credentials are not automatically sent to another provider as a fallback.

The implementation provides MOVA-specific cloud routing, app identity, tenant, request signing and token refresh. Saved credentials retain the provider; old records without a provider remain Dreame records. Changing provider, username or region requires a password rather than silently restoring the previous account.

### What is—and is not—validated

- The display catalog maps **22 model families / 84 exact identifiers** from upstream model data. Unknown identifiers keep a generic fallback.
- Offline tests exercise provider routing, signed requests, refresh, credential compatibility and model lookup. They do not establish a successful real MOVA login.
- **No real MOVA account or robot has been available for validation. Live authentication, map retrieval/decoding, photos, voice installation and physical controls are unverified.** No robot movement command was issued for this update.
- Common status, command and map paths reuse the protocol implementation; feature availability varies by model. Catalog membership is not a compatibility certificate.
- Packed cleaning-mode encoding is limited to 78 audited identifiers and additionally requires the self-wash-base property to be reported. Unrecognized finer wetness scales cannot be overwritten with the legacy three-level water setting.
- MOVA target navigation is **not enabled**. Existing Dreame navigation restrictions are unchanged.

Starting with v0.2.3, the source and DMG include **21 transparent manufacturer product PNGs for the 22 catalog families**, matched by exact model identifier. V50 Ultra and V50 Ultra Complete share the same robot/base image; the Complete accessory bundle is not pictured. Unknown models retain a neutral fallback. Image color represents the product family and is not detected from the robot. No AI-generated product substitutes are used; E40's official transparent WebP was converted losslessly to PNG.

Artwork remains third-party material and is **not covered by the source-code MIT license**. No redistribution license, endorsement or trademark rights are asserted. Original source URLs and attribution are retained in [SOURCES.json](../Sources/DreameHub/Resources/assets/products/mova/SOURCES.json); see [third-party notices](../THIRD_PARTY_NOTICES.md).

If you test a MOVA device, report the model ID, application version, account provider/region, exact error and which read-only functions worked. Do not share passwords, verification codes, tokens, private maps or object photos. [Device report](https://github.com/retoucheroz/dreamehub/issues/new?template=device-report.yml).

## Türkçe

v0.2.2, mevcut menü çubuğu tasarımını koruyarak **Dreame Home / MOVA Home** hesap seçimini ekler. Robotun kayıtlı olduğu hizmeti, ardından hesabın sunucu bölgesini seçin. Dreame Home'a kayıtlı MOVA markalı robot için Dreame Home seçeneği kullanılır. Hesap bilgileri alternatif olarak başka sağlayıcıya otomatik gönderilmez.

MOVA için ayrı bulut adresi, uygulama kimliği, tenant, istek imzası ve oturum yenileme uygulanmıştır. Kayıtlı hesap sağlayıcıyı da saklar; sağlayıcı alanı olmayan eski kayıtlar Dreame olarak açılır. Sağlayıcı, kullanıcı adı veya bölge değişince eski hesap sessizce yüklenmez; parola yeniden istenir.

### Doğrulanan ve doğrulanmayan kapsam

- Görsel kimlik kataloğu upstream veriden **22 model ailesi / 84 tam kimlik** eşleştirir. Bilinmeyen kimliklerde nötr görünüm korunur.
- Çevrimdışı testler sağlayıcı yönlendirmesini, imzalı istekleri, oturum yenilemeyi, kayıtlı hesap uyumluluğunu ve model eşleşmesini sınar. Bunlar gerçek MOVA girişinin başarılı olduğunu kanıtlamaz.
- **Gerçek MOVA hesabı veya robotuyla doğrulama yapılmadı. Canlı giriş, harita alma/çözme, fotoğraflar, ses kurulumu ve fiziksel kontroller doğrulanmamıştır.** Bu güncellemede robot hareket komutu gönderilmedi.
- Ortak durum, komut ve harita akışları mevcut protokol uygulamasını kullanır; özellikler modele göre değişir. Katalogda olmak uyumluluk belgesi değildir.
- Birleşik temizlik modu kodlaması incelenmiş 78 kimlikle sınırlıdır; ayrıca cihazın yıkama istasyonu özelliğini bildirmesi gerekir. Tanınmayan hassas ıslaklık ölçeği eski üç seviyeli su ayarıyla ezilmez.
- MOVA için hedefe gitme **açık değildir**. Dreame'in mevcut hedefe gitme sınırları değişmedi.

v0.2.3'ten itibaren kaynak ve DMG, tam model kimliğiyle eşleştirilen **22 katalog ailesi için 21 şeffaf üretici ürün PNG'sini içerir**. V50 Ultra ve V50 Ultra Complete aynı robot/istasyon görselini kullanır; Complete aksesuar paketi gösterilmez. Bilinmeyen modellerde nötr görsel korunur. Görsel rengi model ailesini temsil eder, robottan algılanmaz. AI ile üretilmiş benzer ürünler kullanılmaz; E40'ın resmî şeffaf WebP'si kayıpsız olarak PNG'ye dönüştürülmüştür.

Görseller üçüncü taraf materyalidir ve **kodun MIT lisansı kapsamında değildir**. Yeniden dağıtım lisansı, marka hakkı veya üretici onayı iddia edilmez. Asıl kaynak URL'leri ve atıflar [SOURCES.json](../Sources/DreameHub/Resources/assets/products/mova/SOURCES.json) içinde korunur; [üçüncü taraf bildirimleri](../THIRD_PARTY_NOTICES.md).

MOVA cihazınızı denerseniz model kimliği, uygulama sürümü, hesap sağlayıcısı/bölgesi, tam hata ve çalışan yalnız-okuma işlevlerini bildirin. Parola, doğrulama kodu, token, özel ev haritası veya nesne fotoğrafı paylaşmayın. [Cihaz raporu](https://github.com/retoucheroz/dreamehub/issues/new?template=device-report.yml).

## Protocol references / Protokol kaynakları

- [Upstream protocol](https://github.com/Tasshack/dreame-vacuum/blob/master/custom_components/dreame_vacuum/dreame/protocol.py)
- [Upstream model table](https://dreame-vacuum.tasshack.com/guide/more/supported-devices#mova)
- [MOVA official product catalog](https://www.mova.tech/collections/robot-vacuum)
