# Model catalog / Tanınan modeller

[English](../README.md) · [Türkçe](../README.tr.md)

These product names were joined to exact model IDs present in the Swift map registry on 2026-10-18, using the [Dreame Vacuum integration's model table](https://dv.tasshack.com/guide/more/supported-devices). One matching identifier is shown per product; regional variants may have other IDs.

Bu ürün adları, Dreame Vacuum entegrasyonunun model tablosuyla Swift harita kaydındaki tam kimlikler eşleştirilerek 2026-10-18 tarihinde kontrol edildi. Her ürün için bir eşleşen kimlik gösterilir; bölgesel sürümlerin başka kimlikleri olabilir.

| Model | Matching identifier / Eşleşen kimlik |
|---|---|
| L10s Pro Ultra Heat | `r2338a`, `r2377`, `r2338h` |
| L10s Pro Ultra | `r9309a` |
| L10s Ultra Gen 2 | `r2469a` |
| L10s Pro Gen 2 | `r2364` |
| L20 Ultra | `r2253b` |
| L40 Ultra | `r2492a` |
| L40 Ultra Gen 2 | `r501t` |
| L40s Ultra | `r2551a` |
| L40s Ultra AE | `r2579c` |
| L40s Ultra CE | `r2562c` |
| L50 Ultra | `r9493a` |
| L60 Pro Ultra | `r501da` |
| L60 Ultra | `r5090a` |
| L60 Ultra PE | `r50397` |
| X40 Ultra | `r2416a` |
| X50 Ultra | `r2489a` |
| X60 Ultra | `r5089b` |
| Matrix10 Ultra | `r2513` |
| Matrix10 Pro | `r5082a` |
| Aqua10 Ultra Roller | `r9535a` |
| Aqua10 Roller AE | `r501ba` |
| Aqua10 Roller | `r9533a` |
| D9 Max Gen 2 | `r2422` |
| D20 Air Plus | `r531ra` |
| D20 Plus | `r2564b` |
| D20 Pro Plus | `r2566a` |
| D30 Ultra | `r50573` |
| D30 Ultra CE | `r500yb` |

Identifiers in the table above use the prefix `dreame.vacuum.`. This is recognition/map-format coverage, not universal feature validation. Features vary by model; only L10s Pro Ultra Heat `r2338a` has read-only device validation here. Swift physical commands are not live-verified. Target navigation remains restricted to the three L10s Pro Ultra Heat identifiers above; MOVA is not added to that allowlist.

Yukarıdaki kimliklerin öneki `dreame.vacuum.` şeklindedir. Liste, model/harita biçimi tanınmasını belirtir; tüm özelliklerin doğrulandığı anlamına gelmez. Özellikler modele göre değişir. Yalnız L10s Pro Ultra Heat `r2338a` cihazında okuma doğrulandı; Swift fiziksel komutları canlı doğrulanmadı. Hedefe gitme yukarıdaki üç L10s Pro Ultra Heat kimliğiyle sınırlı kalır; MOVA bu izin listesine eklenmez.

The older product-name catalog also contains L60 Ultra FE and X60 Max Ultra Complete, but an exact name-to-ID join was not established in this check, so they are not listed as matched models. / Eski ürün adı kataloğunda L60 Ultra FE ve X60 Max Ultra Complete de bulunur; bu incelemede tam ad-kimlik eşleşmesi kurulamadığından eşleşen listeye alınmadılar.

Source implementation: [map registry](../Sources/DreameCore/MapService.swift), [control allowlist](../Sources/DreameCore/DeviceContract.swift). The account supplies the actual display name. / Kaynak uygulama: harita kaydı ve kontrol listesi. Görünen gerçek ad hesaptan alınır.

## MOVA preview catalog / MOVA önizleme kataloğu

22 families and 84 exact identifiers, checked against upstream model data on 2026-10-19. **No real MOVA account or device has been tested.** Recognition does not establish map decoding or control support for every model. / 22 aile ve 84 tam kimlik, 2026-10-19 tarihinde upstream model verisiyle eşleştirildi. **Gerçek MOVA hesabı veya cihazı test edilmedi.** Tanınması her modelin haritasının ya da kontrollerinin çalıştığını kanıtlamaz.

| Model family / Model ailesi | Example exact identifier / Örnek tam kimlik |
|---|---|
| E20 Plus | `dreame.vacuum.r2459a` |
| E30 Ultra | `dreame.vacuum.r2427` |
| E40 Ultra | `mova.vacuum.r5732a` |
| E50 Pro Ultra | `mova.vacuum.r6710a` |
| E50 Ultra | `mova.vacuum.r6709a` |
| M1 | `dreame.vacuum.r2380` |
| MOBIUS 60 | `mova.vacuum.r2599h` |
| P50 Pro Ultra | `mova.vacuum.r2475a` |
| P50 Ultra | `mova.vacuum.r2519a` |
| P70 Pro Ultra | `mova.vacuum.r5977a` |
| S10 Plus | `dreame.vacuum.r2383a` |
| S70 Roller | `mova.vacuum.r5769a` |
| S70 Ultra Roller | `mova.vacuum.r5770a` |
| V50 Ultra | `mova.vacuum.r2525a` |
| V50 Ultra Complete | `mova.vacuum.r2582a` |
| V70 Ultra Complete | `mova.vacuum.r5979a` |
| V70 Ultra Complete X | `mova.vacuum.r59795` |
| V70 Ultra Pure | `mova.vacuum.r5978a` |
| Z50 Ultra | `mova.vacuum.r2430a` |
| Z60 Ultra Roller Complete | `mova.vacuum.r9540a` |
| Z60 Ultra Roller Standalone | `mova.vacuum.r9544a` |
| Z70 Ultra Roller Complete | `mova.vacuum.r5765h` |

All regional identifiers are in [ProductCatalog.swift](../Sources/DreameCore/ProductCatalog.swift). No prefix guessing is used. Grouped cleaning-mode encoding is separately limited to [78 audited identifiers](../Sources/DreameCore/VerifiedMovaCapabilities.swift) and requires a self-wash-base property reported by the device. Unrecognized finer wetness scales are not overwritten with three-level settings. The public DMG uses neutral artwork, not unlicensed manufacturer PNGs. [MOVA integration scope](MOVA.md).

Tüm bölgesel kimlikler `ProductCatalog.swift` içindedir; önek tahmini yapılmaz. Birleşik temizlik modu kodlaması ayrıca incelenmiş 78 kimlikle sınırlıdır ve cihazın yıkama istasyonu özelliğini bildirmesi gerekir. Tanınmayan hassas ıslaklık ölçekleri üç seviyeli ayarlarla ezilmez. Herkese açık DMG, yeniden dağıtım izni doğrulanmamış üretici PNG'leri yerine nötr görseller kullanır.
