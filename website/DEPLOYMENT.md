# LustrousLux Web Sitesi Yayınlama Rehberi

Kral, siteni (`lustrouslux.com`) yayına almak için en hızlı ve ücretsiz yöntem **Netlify** kullanmaktır. Hiçbir kod bilgisine gerek kalmadan "Sürükle-Bırak" yöntemiyle halledebilirsin.

## Yöntem 1: Netlify (En Kolayı)

1.  **Netlify'a Üye Ol**: [netlify.com](https://netlify.com) adresine git ve (GitHub veya Email ile) giriş yap.
2.  **Sürükle Bırak**:
    *   Giriş yaptıktan sonra "Sites" sekmesine gel.
    *   Masaüstündeki `psp/website` klasörünü tut ve tarayıcıdaki o alana sürükleyip bırak.
    *   Saniyeler içinde siten yayına girecek ve sana rastgele bir isim verecek (örn: `stunning-lux-123.netlify.app`).

3.  **Domain Bağlama (lustrouslux.com)**:
    *   Netlify panelinde, yüklediğin sitenin **"Domain Settings"** (veya "Site Configuration" > "Domain Management") kısmına gir.
    *   **"Add Custom Domain"** butonuna bas.
    *   `lustrouslux.com` yaz ve "Verify" de.

4.  **DNS Ayarları (Domaini Aldığın Yer)**:
    *   Domaini nereden aldıysan (GoDaddy, Namecheap, Google Domains vb.) oranın paneline gir.
    *   **DNS Yönetimi** (DNS Management) sayfasına gel.
    *   Netlify sana **Nameservers** verecek (örn: `dns1.p01.nsone.net`, `dns2...`).
    *   Kendi domain panelindeki Nameserver'ları silip, Netlify'ın verdiklerini yapıştır.
    *   Kaydet. (Yayılması 1-24 saat sürebilir ama genellikle 15 dk'da olur).

## Yöntem 2: Dosyaları Sunucuya Atmak (FTP/Cpanel)

Eğer zaten bir hosting'in (sunucun) varsa:
1.  Hosting paneline (cPanel/Plesk) gir.
2.  **Dosya Yöneticisi**'ni aç.
3.  `public_html` klasörünün içine gir.
4.  Bizim `website` klasörü içindeki `index.html` ve `style.css` dosyalarını oraya yükle.
5.  Tamamdır.

## Önemli Not: Update Dosyası (APK)
Kullanıcılar "DOWNLOAD UPDATE" butonuna bastığında güncel APK'yı indirmeli.

1.  Uygulamanın AAB/APK çıktısını al (`flutter build apk --release`).
2.  Bu dosyayı `app-release.apk` olarak adlandır.
3.  Web sitesi dosyalarının yanına (index.html'in yanına) bu `.apk` dosyasını da koy.
4.  `index.html` dosyasını aç ve butonu şöyle güncelle:
    ```html
    <!-- Eski -->
    <a href="#" class="btn-gold">DOWNLOAD UPDATE</a>

    <!-- Yeni -->
    <a href="app-release.apk" class="btn-gold">DOWNLOAD UPDATE</a>
    ```
5.  Tekrar Netlify'a sürükle (veya sunucuya at).

Böylece kullanıcı siteye girip butona basınca direkt güncel uygulamayı indirecek! 🚀
