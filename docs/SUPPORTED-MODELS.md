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

Identifiers use the prefix `dreame.vacuum.`. This is recognition/map-format coverage, not universal feature validation. Features vary by model; only L10s Pro Ultra Heat `r2338a` has read-only device validation here. Swift physical commands are not live-verified. Target navigation/grouped settings are currently restricted to the three L10s Pro Ultra Heat identifiers above.

Kimliklerin öneki `dreame.vacuum.` şeklindedir. Liste, model/harita biçimi tanınmasını belirtir; tüm özelliklerin doğrulandığı anlamına gelmez. Özellikler modele göre değişir. Yalnız L10s Pro Ultra Heat `r2338a` cihazında okuma doğrulandı; Swift fiziksel komutları canlı doğrulanmadı. Hedefe gitme/birleşik ayarlar şu an yukarıdaki üç L10s Pro Ultra Heat kimliğiyle sınırlıdır.

The older product-name catalog also contains L60 Ultra FE and X60 Max Ultra Complete, but an exact name-to-ID join was not established in this check, so they are not listed as matched models. / Eski ürün adı kataloğunda L60 Ultra FE ve X60 Max Ultra Complete de bulunur; bu incelemede tam ad-kimlik eşleşmesi kurulamadığından eşleşen listeye alınmadılar.

Source implementation: [map registry](../Sources/DreameCore/MapService.swift), [control allowlist](../Sources/DreameCore/DeviceContract.swift). The account supplies the actual display name. / Kaynak uygulama: harita kaydı ve kontrol listesi. Görünen gerçek ad hesaptan alınır.
