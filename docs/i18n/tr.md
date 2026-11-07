<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-0A84FF?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**Uygulama, ve arkasında bıraktığı her şey.**

Bir uygulamayı Çöp Sepeti’ne sürüklemek yalnızca simgeyi kaldırır. Tercihler, önbellekler, kapsayıcılar, günlükler ve açılış aracıları Kitaplık’ta kalır. Yer kaplamaya devam eder ve yeniden kurunca geri gelir.

Banish bu dosyaları bulur, bir şey taşınmadan önce gösterir ve yalnızca seçtiklerini Çöp Sepeti’ne gönderir. Her öğeyi geri koyabilirsin. Hiçbir şey kalıcı olarak silinmez.

<p><img src="../images/library.png" alt="Banish içindeki yüklü uygulamalar" width="920"></p>

## Ne görürsün

Kenar çubuğu yüklü uygulamaları sürüm ve boyutla listeler. Yeşil nokta, uygulamanın çalıştığını gösterir. Arama bir ad ya da `com.google.Chrome` gibi bir paket kimliği kabul eder.

Üç sayı görünür: uygulamanın boyutu, ilgili dosyaların boyutu ve seçilip Çöp Sepeti’ne gidecek olanın boyutu.

**İlgili dosyalar** paket kimliğiyle eşleşir ve baştan seçilidir. **Ad eşleşmeleri** yalnızca adı paylaşır, bu yüzden yolu incelemeden seçili kalmaz.

<p><img src="../images/detail.png" alt="Banish içinde Chrome ve ilgili dosyaları" width="920"></p>

## Onaylamadan hiçbir şey hareket etmez

**Move to Trash** sayı ve boyutu gösteren bir sayfa açar. Düğme varsayılan düğme değildir, bu yüzden Return yanlışlıkla onaylamaz.

`/Applications` içindeki uygulamalar macOS’a aittir ve normal taşıma reddedilir. Sayfa, parolanın gerekebileceğini söyler. Onaydan sonra macOS bir kez sorar ve Banish seçimi Çöp Sepeti’ne taşır.

<p><img src="../images/confirm.png" alt="Chrome Çöp Sepeti’ne gitmeden önceki onay" width="920"></p>

Parola penceresini iptal etmek taşımayı durdurur. Taşınmayan yerinde kalır. Sepete ulaşan geri alınabilir.

## Nereye bakar

Banish diskin tamamını taramaz. Bilinen Kitaplık klasörlerine, bir ya da iki düzey bakar: tercihler, Application Support, önbellekler, günlükler, kapsayıcılar, kimlik eşleşince web verisi, açılış aracıları ve kayıtlı durum.

Güçlü bir eşleşme paket kimliğini kullanır. `com.foo.app`, `com.foo.application` ya da `com.foo.app2` dosyalarını toplamaz. `Google/Chrome` Chrome’a ait olabilir. `Google/Earth`, tek bir kelime ortak diye ait olmaz.

## Neye dokunmaz

`/System`, `/usr`, `/bin` ve `/private` gibi sistem yerleri. Belgelerin, Masaüstü, İndirilenler, fotoğraflar ve müzik. Mail, Mesajlar, Fotoğraflar, Safari, anahtarlıklar, Takvim ve Notlar. `~/.ssh` ve silme kaynağı olarak Çöp Sepeti’nin kendisi. Sembolik bağlantılar. Ve çalışan Banish kopyası: uygulama kendini taşıyamaz.

Finder, Safari ve Mail gibi temel Apple uygulamaları kilitli kalır. Keynote, Pages ve Numbers gibi isteğe bağlı Apple uygulamaları açık bir uyarıyla kaldırılabilir. Sistem uygulamaları başta gizlidir. Görünüm menüsünden ya da Ayarlar’dan gösterilir.

## İzinler

**Yönetici parolası** yalnızca macOS bir uygulamayı Uygulamalar klasöründen çıkarmayı reddettiğinde istenir. Pencere sistem penceresidir ve Banish adını taşır.

**Tam Disk Erişimi** isteğe bağlıdır. macOS’un gizlediği kapsayıcıları ve önbellekleri okumayı sağlar. Olmadan liste çalışmaya devam eder ve bir klasör okunamazsa bir şerit görünür.

Sistem Ayarları → Gizlilik ve Güvenlik → Tam Disk Erişimi

## Uygulamanın içindeki dil

Pencere Mac’in dilini izler; Arapçada sağdan sola. Ayarlar Arapçayı ya da İngilizceyi sabitleyebilir.

<p><img src="../images/settings.png" alt="Banish ayarları" width="540"></p>

## Derlemek

macOS 14 veya daha yenisi ve Swift 6. Üçüncü taraf kitaplık yok.

```bash
./Scripts/build-app.sh
open build/Banish.app
```

Ya da `make app` ve `make run`. Testler `make test` ile çalışır. İmzalı uygulama `build/Banish.app` içindedir.
