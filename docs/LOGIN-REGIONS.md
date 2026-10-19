# Giriş ve sunucu bölgesi / Login and server region

[Türkçe README](../README.tr.md) · [English README](../README.md)

## Türkçe

**Önce hesap sağlayıcısını seçin:** robotunuz Dreame Home'da kayıtlıysa **Dreame Home**, MOVA Home'da kayıtlıysa **MOVA Home**. Robotun markası tek başına hesap sağlayıcısını belirlemez. Hesap bilgileri diğer markanın sunucularında otomatik denenmez. MOVA bağlantısı henüz gerçek hesap veya cihazda doğrulanmamıştır; [kapsam](MOVA.md).

**Sunucu bölgesi, şu anda bulunduğunuz ülke değildir.** Hesabınızın ve robotunuzun kayıtlı olduğu bulut sunucusunu seçmelisiniz. Önce resmî **Dreame Home / MOVA Home** uygulamasında kullandığınız hesabı ve hesap bölgesini kontrol edin. Kanada'da bulunmak tek başına ABD sunucusunu doğrulamaz.

| Dreame Hub seçeneği | Sunucu kodu | Ne zaman seçilmeli? |
| --- | --- | --- |
| Avrupa | `eu` | Avrupa sunucusunda kayıtlı hesaplar için. |
| Singapur / Diğer | `sg` | Singapur/diğer uluslararası sunucuya kayıtlı hesaplar için; Avrupa ile bağlanamayan bazı hesaplarda doğru seçenek olabilir. |
| ABD | `us` | ABD sunucusuna kayıtlı hesaplar için. |
| Çin | `cn` | Çin sunucusuna kayıtlı hesaplar için. |
| Rusya | `ru` | Rusya sunucusuna kayıtlı hesaplar için. |

### Türkiye’den bağlanıyorsanız

Türkiye’de olmanız otomatik olarak **Avrupa** seçmeniz gerektiği anlamına gelmez. Hesap bilgileri doğru olduğu hâlde Avrupa ile giriş reddediliyorsa veya robot bulunamıyorsa, hesabınızın bölgesini kontrol ettikten sonra **Singapur / Diğer** seçeneğini deneyebilirsiniz. Bu, bütün Türkiye hesaplarının Singapur’da olduğu veya her giriş hatasının bölgeden kaynaklandığı anlamına gelmez.

### Giriş reddediliyor veya robot görünmüyor

1. Aynı hesapla resmî Dreame Home veya MOVA Home uygulamasına giriş yapabildiğinizi ve robotun orada göründüğünü kontrol edin. Dreame Hub, kullanıcı adı/e-posta ve **seçilen hizmetin hesap parolası** ile giriş yapar; Wi-Fi parolasını kullanmayın.
2. Apple/Google gibi bir sağlayıcıyla giriş yapıyorsanız, sağlayıcınızın parolasını Dreame Hub’a yazmayın. Hesabınızın ayrıca Dreame/MOVA parolası olup olmadığını resmî uygulamanın hesap/parola seçeneklerinden kontrol edin; destekleniyorsa parola belirleme veya sıfırlama işlemini oradan yapın.
3. Doğru hesap bölgesini seçin. Dreame Hub şu anda başarısız girişte diğer sunucuları otomatik taramaz. Bölgeyi rastgele ve art arda denemek yerine önce hesabın kayıtlı bölgesini doğrulayın.
4. **Kayıtlı hesabın sağlayıcısını, kullanıcı adını veya bölgesini değiştirdiyseniz parolayı yeniden yazın.** v0.2.2'de boş parola yalnız kayıtlı hesapla bu alanlar eşleşiyorsa kullanılabilir; eski bölge veya sağlayıcı sessizce geri yüklenmez. Başarılı girişte “Bilgilerimi hatırla” seçiliyse yeni bilgiler kaydedilir. Daha eski sürümlerdeki boş parola/eski bölge davranışı için v0.2.2'ye güncelleyin.
5. Hâlâ bağlanamıyorsanız hata mesajını ve seçtiğiniz bölgeyi not edin; parola, erişim anahtarı veya hesap kimlik bilgilerini paylaşmayın. Art arda giriş denemelerini durdurup ağ/servis durumunu ve resmî uygulamadaki girişi kontrol edin.

Sunucu seçimini değiştirmek hesabınızı veya robotunuzu başka bölgeye **taşımaz**. Bu sorunu çözmek için robotu sıfırlamanız ya da resmî uygulamadaki hesap bölgesini değiştirmeniz gerekmez.

## English

**Select the account provider first:** use **Dreame Home** if that is where your robot is registered, or **MOVA Home** for a MOVA Home account. The robot's brand alone does not identify its account provider. Credentials are never automatically tried against the other brand's service. MOVA login has not yet been validated with a real account or device; [scope](MOVA.md).

**Server region is not your current physical location.** Select the cloud server where your account and robot are registered. Start by checking the account and region used in the official **Dreame Home / MOVA Home** app. Being in Canada alone does not confirm that the US server is correct.

| Dreame Hub option | Server code | When to use it |
| --- | --- | --- |
| Europe / Avrupa | `eu` | Accounts registered on the European server. |
| Singapore / Other — Singapur / Diğer | `sg` | Accounts on the Singapore/other international server; this may be the correct choice for some accounts that cannot connect through Europe. |
| USA / ABD | `us` | Accounts registered on the US server. |
| China / Çin | `cn` | Accounts registered on the Chinese server. |
| Russia / Rusya | `ru` | Accounts registered on the Russian server. |

### Connecting from Türkiye

Being in Türkiye does not automatically mean you should select **Europe**. If Europe rejects otherwise correct credentials or returns no robot, check your account region and consider **Singapore / Other**. This is an alternative for some accounts, not a universal fix or a claim that all Turkish accounts use Singapore.

### Login rejected or robot missing

1. Check that you can sign in to the official Dreame Home or MOVA Home app with the same account and see your robot there. Dreame Hub uses a username/email and **the selected service's account password**, not your Wi-Fi password.
2. If you use Apple/Google or another sign-in provider, do not enter that provider’s password into Dreame Hub. Check the official app’s account/password options for a separate Dreame/MOVA password; set or reset it there if your account supports that option.
3. Select the correct account region. Dreame Hub does not automatically try other servers after a failed login. Avoid repeated random attempts; verify the account’s registered region first.
4. **Re-enter your password when changing a saved account's provider, username or region.** In v0.2.2, an empty password can reuse saved credentials only when those fields match; the previous provider or region is not silently restored. A successful login saves the new details when “Remember me” is enabled. Update older versions to v0.2.2 to avoid their blank-password/old-region behavior.
5. If connection still fails, note the error and selected region without sharing passwords, tokens, or account credentials. Stop repeated attempts and check your network/service availability and login in the official app.

Changing Dreame Hub’s server selection does **not migrate** your account or robot. You do not need to reset the robot or change the account region in the official app to troubleshoot this selection.
