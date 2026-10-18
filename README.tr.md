# Dreame Hub

### Dreame’in, artık Mac’inde.

Türkçe · [English](README.md)

[![macOS için indir](https://img.shields.io/badge/macOS_i%C3%A7in_indir-Apple_Silicon-3478F6?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/retoucheroz/dreamehub/releases/download/v0.2.1/Dreame-Hub-Swift-0.2.1-preview-arm64.dmg)

**[v0.2.1 DMG indir](https://github.com/retoucheroz/dreamehub/releases/download/v0.2.1/Dreame-Hub-Swift-0.2.1-preview-arm64.dmg)** · macOS 13+ · M1/M2/M3/M4 ve sonraki Apple Silicon Mac’ler. DMG’yi aç, uygulamayı Applications klasörüne sürükle, başlat ve menü çubuğundaki ikonunu kullan. Bu önizleme ad-hoc imzalıdır; Apple noter onayı yoktur. İlk açılışta Gizlilik ve Güvenlik bölümünden onay gerekebilir. Bu indirme Intel Mac’leri desteklemez. [Sürüm notları](https://github.com/retoucheroz/dreamehub/releases/tag/v0.2.1).

Robotunu kontrol et, haritasını keşfet, gördüğü nesneleri incele. Hepsi macOS menü çubuğundan açılan sade bir panelde. **Robota root gerekmez. Python çalıştırılmaz.** Swift ile geliştirilir; mevcut arayüz Apple WKWebView içinde korunur.

![Dreame Hub özet ekranı ve temizlik kontrolleri](docs/media/app-overview.jpg)

## Temizliğin kontrolü elinin altında

**Menü çubuğundan tek tıkla.** Pili ve temizlik ilerlemesini gör, emiş ve mop ayarlarını seç; temizliği başlat, duraklat, durdur veya robotu istasyonuna gönder. Mop yıkama, kurutma ve hazne boşaltma işlemlerine aynı panelden ulaş.

**Evine farklı bir açıdan bak.** 3D haritayı yakınlaştır, döndür ve incele. Önceki temizliklere dön, kayıtlı rotayı gör veya haritada bir hedef seç. Robot simgesi alınan gerçek konum ve yönler arasında yumuşakça ilerler; veri gelmediğinde son ölçümde durur, hareket uydurmaz.

![Dreame Hub harita görünümü](docs/media/map.jpg)

**Robotunun fark ettiklerini gör.** Kayıtlı nesne algılarını ve varsa fotoğraflarını doğrudan haritadan aç. Fotoğraf erişimi robota ve kaydın içeriğine bağlıdır.

![Kayıtlı nesnenin fotoğrafı](docs/media/photo.jpg)

**Robotunun sesini kişiselleştir.** Anonsları listele, Mac üzerinde dinle ve kendi ses dosyalarınla değiştirmek için özel paket hazırla. Fırça, filtre ve istasyon bakımını da aynı uygulamadan takip et.

![Ses önizlemeleri ve özel ses kontrolleri](docs/media/voice.jpg)

## Kullanırken gör

https://github.com/user-attachments/assets/c0216a06-294b-4b40-84a7-342442fc6f57

[Yatay kullanım videosu](docs/media/actual-ui-landscape.mp4) · [Dikey kullanım videosu](docs/media/actual-ui-portrait.mp4)

30 saniyelik tanıtımlarda gerçek arayüz, haritada yakınlaştırma ve orbit, duvar kontrolleri, rota izi, harita noktaları, wireframe, 2D/3D/Clay/POV görünümleri, nesne fotoğrafları ve ses özelleştirme özgün elektronik müzik eşliğinde gösterilir. Çekimdeki robot hareketi simülasyondur; fiziksel robot çalıştırılmadı.

## Başlangıç

[Görsel kurulum ve macOS güvenlik rehberi](docs/INSTALL.md) · [Giriş ve sunucu bölgesi yardımı](docs/LOGIN-REGIONS.md)

![Applications’a taşıma ve macOS engellerse yalnız bu uygulama için açılış onayı](docs/media/install-guide.svg)

**Giriş bölgesi:** yaşadığın ülkeyi değil Dreamehome hesabının kayıtlı olduğu sunucuyu seç. Doğru hesap bilgileriyle Avrupa girişini reddediyor veya robotu göstermiyorsa Singapur / Diğer alternatif olabilir. ABD, Çin ve Rusya da o sunucularda kayıtlı hesaplar içindir. Kayıtlı bölgeyi değiştirirken parolayı yeniden yaz; boş bırakırsan eski kayıtlı bölge kullanılabilir. [Tüm seçenekler ve çözüm adımları](docs/LOGIN-REGIONS.md).

Apple Silicon Mac, macOS 13 veya üzeri ve Dreame hesabı gerekir. Giriş yap, robotunu seç ve menü çubuğu ikonundan Dreame Hub’ı aç. Kaydedilen hesap bilgileri macOS Anahtar Zinciri’nde kalır.

Kaynaktan derlemek için uyumlu Swift araçlarını kur ve çalıştır:

```sh
bash build-app.sh
open "build/Dreame Hub Swift.app"
```

Robota komut göndermeden incelemek için açılış komutuna `--args --read-only` ekle. Özel ses dönüştürme isteğe bağlı yerel libsndfile kurulumunu kullanır; [derleme ayrıntıları](docs/BUILD.md).

## Modeller

Model kataloğunda **L10s Pro Ultra Heat, L20 Ultra, L40/L40s Ultra, L50 Ultra, L60 Ultra, X40/X50/X60 Ultra, Matrix10, Aqua10, D20 ve D30 çeşitleri** bulunur. [Tam model listesi ve özellik kapsamı](docs/SUPPORTED-MODELS.md).

<sub>Swift önizlemesi bir L10s Pro Ultra Heat üzerinde yalnız okuma ile kontrol edildi. Fiziksel komutlar ve hareket hâlindeki güncelleme gecikmesi Swift’te henüz canlı doğrulanmadı. 3D görünüm gerçek 2D haritanın perspektifidir; ham 3D LiDAR veya kamera akışı değildir. [Doğrulama ayrıntıları](docs/VERIFICATION.md).</sub>

---

Dreame veya Apple ile bağlantılı olmayan, bağımsız bir uygulamadır. Özellikler modele göre değişir. Kaynak paketinde nötr görseller kullanılır; tanıtım özel uygulamanın gerçek arayüzünden kaydedildi. [Üçüncü taraf bildirimleri](THIRD_PARTY_NOTICES.md) · [MIT lisansı](LICENSE).
