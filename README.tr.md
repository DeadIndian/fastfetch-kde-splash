<div align="center">

# Deads Fastfetch Splash Screen (Forked)

### KDE Plasma için matris tarzı açılış ekranı — gerçek sistem bilgisi, tam renkli

[herzane52/fastfetch-kde-splash](https://github.com/herzane52/fastfetch-kde-splash) projesinin fork'u. `fastfetch` çıktısını glitch karakter-belirme animasyonuyla açılış ekranına taşır — ve orijinalden farklı olarak **terminalinizin ANSI renklerini** (256 renk ve truecolor) olduğu gibi korur.

[![License](https://img.shields.io/github/license/DeadIndian/fastfetch-kde-splash?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/github/v/release/DeadIndian/fastfetch-kde-splash?style=flat-square)](https://github.com/DeadIndian/fastfetch-kde-splash/releases)
[![Stars](https://img.shields.io/github/stars/DeadIndian/fastfetch-kde-splash?style=flat-square)](https://github.com/DeadIndian/fastfetch-kde-splash/stargazers)
[![Made with QML](https://img.shields.io/badge/made%20with-QML-blue?style=flat-square)](contents/splash/Splash.qml)

[English](README.md) | [Türkçe](README.tr.md)

<p>
  <img src="assets/screenshots/hero.gif" alt="Fastfetch KDE Splash ekran kaydı" width="80%" />
</p>

</div>

---

## 📖 İçindekiler

- [Hakkında](#-hakkında)
- [Özellikler](#-özellikler)
- [Demo](#-demo)
- [Gereksinimler](#-gereksinimler)
- [Kurulum](#-kurulum)
- [Yapılandırma](#-yapılandırma)
- [Ayarları Sonradan Değiştirme](#-ayarları-sonradan-değiştirme)
- [Kaldırma](#-kaldırma)
- [Katkıda Bulunma](#-katkıda-bulunma)
- [Lisans](#-lisans)
- [Teşekkürler](#-teşekkürler)

---

## 🎯 Hakkında

Durağan bir yüklenme göstergesi yerine, açılış ekranınız canlı `fastfetch` çıktısını — işletim sistemi logosu ve sistem bilgisi — rastgele sırada, karakter karakter "glitch" efektiyle çözerek gösterir. Masaüstünüz hazır olduğunda açılış ekranı otomatik olarak kapanır.

Bu fork, orijinalin üzerine iki büyük özellik ekler: **tam ANSI renk desteği** (açılış ekranı terminalinizdeki fastfetch renkleriyle birebir aynı görünür, 24-bit truecolor dahil) ve **sıralı (sequential) düzen modu** — logo ekranın ortasında çözülür, sola kayar, bilgi belirir. Ayrıca orijinalin v1.5'te kazandığı her şeyi de içerir: animasyon hız ayarları, sadece bilgi düzeni ve çok dilli kurulum sihirbazı.

## ✨ Özellikler

- **Gerçek ANSI renkleri** — standart 16, 256 renk ve 24-bit truecolor SGR dizileri olduğu gibi ayrıştırılır ve gösterilir; renkleri soyulmuş tek renk çıktı yok
- **4 düzen modu** — sadece logo, logo + bilgi (full), sıralı (logo çözülür, sola kayar, bilgi belirir), sadece bilgi
- **Glitch belirme animasyonu** — karakterler rastgele sırada çözülür (Fisher–Yates karıştırma), gizliyken düzen korunur
- **Animasyon hızı kontrolü** — hızlı / normal / yavaş ön ayarları veya tamamen özel zamanlama (glitch aralığı, giriş/çıkış süreleri, minimum süre, kare başına karakter)
- **Tema rengi ve arka plan** — parıltı rengi ve arka plan (herhangi HEX veya şeffaf) kurulumda ayarlanır
- **Etkileşimli kurulum sihirbazı** — düz `bash`, bağımlılık yok; dilinizi otomatik algılar (`lang/` dosyaları, çevirisi kolay)
- **Sağlam hata yönetimi** — güvenlik zamanlayıcısı fastfetch eksik/hatalıysa takılmak yerine okunabilir bir hata gösterir

## 📸 Demo

|                         Sadece logo                         |                     Full (logo + bilgi)                     |
| :---------------------------------------------------------: | :---------------------------------------------------------: |
| <img src="assets/screenshots/mode-logo.gif" width="100%" /> | <img src="assets/screenshots/mode-full.gif" width="100%" /> |

---

|                              Sıralı                               |                        Sadece bilgi                         |
| :---------------------------------------------------------------: | :---------------------------------------------------------: |
| <img src="assets/screenshots/mode-sequential.gif" width="100%" /> | <img src="assets/screenshots/mode-info.gif" width="100%" /> |

---

## 📋 Gereksinimler

- **KDE Plasma 6** (`Qt5Compat.GraphicalEffects` / `plasma5support` kullanır)
- **[fastfetch](https://github.com/fastfetch-cli/fastfetch)** kurulu ve `PATH` içinde
- `bash` (kurulum için)

## 🚀 Kurulum

```bash
# 1. fastfetch kurulu olduğundan emin olun
#    Fedora: sudo dnf install fastfetch
#    Arch:   sudo pacman -S fastfetch
#    Debian/Ubuntu: sudo apt install fastfetch

# 2. Depoyu klonlayın ve kurulumu çalıştırın
git clone https://github.com/DeadIndian/fastfetch-kde-splash.git
cd fastfetch-kde-splash
chmod +x install.sh
./install.sh
```

Kurulum sihirbazı dört soru sorar — tema rengi, düzen, arka plan ve animasyon hızı — ve `~/.local/share/plasma/look-and-feel/fork-fastfetch-splash/` altına kurar.

**Etkinleştirme:** \*Sistem Ayarları → Görünüm → Açılış Ekranı → **fork-fastfetch-splash\*** → Uygula. Görmek için çıkış yapıp tekrar girin.

## 💻 Kullanım

Günlük çalıştırılacak bir şey yok — açılış ekranı oturum açılışında devreye girer. Değişiklikleri görmek için çıkış yapıp tekrar girin.

## ⚙️ Yapılandırma

Tüm yapılandırma kurulum sihirbazı üzerinden yapılır (`./install.sh`). Dört soru:

| Ayar       | Seçenekler                                                                                                                                                                                           |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Tema rengi | yok (**varsayılan** — saf fastfetch renkleri, parıltı kapalı) · kırmızı / mavi / yeşil / camgöbeği veya herhangi HEX (örn. `#637C76`) — sadece parıltı; metin renkleri her zaman fastfetch'ten gelir |
| Düzen      | `logo` (sadece logo) · `full` (logo + bilgi) · `info` (sadece bilgi) · `sequential` (logo çözülür, sola kayar, bilgi belirir)                                                                        |
| Arka plan  | siyah / şeffaf veya herhangi HEX                                                                                                                                                                     |
| Hız        | normal / hızlı / yavaş veya glitch aralığı, giriş/çıkış süreleri, minimum süre, kare böleni için özel değerler                                                                                       |

Kurulum sihirbazı seçimlerinizi doğrudan kurulu `Splash.qml` içine yazar (aşağıya bakın).

<details>
<summary>Hız ön ayarı değerleri</summary>

| Ön ayar | Glitch aralığı | Giriş   | Çıkış   | Min. süre | Kare böleni |
| ------- | -------------- | ------- | ------- | --------- | ----------- |
| Hızlı   | 15 ms          | 400 ms  | 800 ms  | 2500 ms   | 25          |
| Normal  | 30 ms          | 800 ms  | 1500 ms | 4000 ms   | 50          |
| Yavaş   | 50 ms          | 1500 ms | 3000 ms | 6000 ms   | 100         |

</details>

## 🔧 Ayarları Sonradan Değiştirme

Kurulumu istediğiniz zaman yeniden çalıştırın:

```bash
./install.sh
```

Ya da kurulu QML dosyasını doğrudan düzenleyin:

```bash
nano ~/.local/share/plasma/look-and-feel/fork-fastfetch-splash/contents/splash/Splash.qml
```

`Splash.qml` dosyasının başındaki özellikler tüm ayarları içerir:

| Özellik             | Açıklama                                               | Varsayılan |
| ------------------- | ------------------------------------------------------ | ---------- |
| `themeColor`        | Parıltı rengi (HEX)                                    | `#ff0000`  |
| `glowEnabled`       | Parıltı açık/kapalı — `false` = saf fastfetch renkleri | `false`    |
| `displayMode`       | `logo` / `full` / `sequential` / `info`                | `logo`     |
| `bgColor`           | Arka plan (HEX veya `transparent`)                     | `#000000`  |
| `glitchInterval`    | Belirme zamanlayıcı aralığı, küçük = hızlı (ms)        | `30`       |
| `introDuration`     | Giriş animasyonu süresi (ms)                           | `800`      |
| `exitDuration`      | Çıkış animasyonu süresi (ms)                           | `1500`     |
| `minSplashDuration` | Minimum görünme süresi (ms)                            | `4000`     |
| `frameDivisor`      | Kare başına karakter böleni, küçük = hızlı             | `50`       |

### Kurulum sihirbazına dil ekleme

Kurulum `$LANG` değişkeninizi otomatik algılar ve `lang/` içindeki eşleşen dosyayı yükler. Yeni dil eklemek için:

```bash
cp lang/en.sh lang/de.sh   # ardından MSG_* ve SPEED_* dizelerini çevirin
LANG=de_DE ./install.sh    # test edin
```

## 🗑️ Kaldırma

```bash
rm -rf ~/.local/share/plasma/look-and-feel/fork-fastfetch-splash
```

Ardından Sistem Ayarları'ndan başka bir açılış ekranı seçin.

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır — yeni düzen modları, yeni kurulum dilleri ve hata düzeltmeleri iyi PR'lardır.

1. Depoyu fork'layın
2. Dal oluşturun (`git checkout -b feature/harika`)
3. Commit edin (`git commit -m 'Harika özellik ekle'`)
4. Push edin (`git push origin feature/harika`)
5. Pull Request açın

## 📄 Lisans

MIT — ayrıntılar için [LICENSE](LICENSE). [herzane](https://github.com/herzane52)'nin orijinal projesinden kod içerir, o da MIT.

## 🙏 Teşekkürler

- **[herzane52/fastfetch-kde-splash](https://github.com/herzane52/fastfetch-kde-splash)** — bu fork'un temeli olan orijinal proje
- **[fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch)** — açılış ekranını besleyen sistem bilgi aracı

---

<div align="center">
<sub><a href="https://github.com/DeadIndian">DeadIndian</a> tarafından ❤️ ile yapıldı</sub>
</div>
