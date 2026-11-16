# Tugas 7

## [Pertanyaan Reflektif](https://pbp.cs.ui.ac.id/assignments/individual/tugas-7.html#pertanyaan-reflektif)

> 1. Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!

Di Flutter, hampir semua yang tampil di layar adalah **widget**: teks, tombol, tata letak, bahkan jarak kosong dan tema. Widget disusun dengan cara menaruh satu widget di dalam widget lain, sehingga terbentuk struktur bertingkat yang disebut **widget tree**[^1]. Pohon ini dimulai dari satu akar (di proyek saya, `MyApp` yang dipasang oleh `runApp`) dan bercabang sampai ke widget paling kecil di ujungnya. Berikut pohon halaman utama aplikasi saya, disederhanakan:

```
MyApp (StatelessWidget)
└── MaterialApp
    └── MyHomePage (StatelessWidget)
        └── Scaffold
            ├── AppBar
            │   └── Text("MyPortfolio")
            └── body: SingleChildScrollView
                └── Padding
                    └── Column
                        ├── Row
                        │   ├── InfoCard (NPM)
                        │   ├── InfoCard (Name)
                        │   └── InfoCard (Class)
                        ├── SizedBox
                        └── Center
                            └── Column
                                ├── Padding → Text("Selamat datang ...")
                                └── GridView.count
                                    └── ItemCard (6 kartu)
                                        └── Material → InkWell → Container
                                            └── Center → Column → Icon, Padding, Text
```

**Hubungan induk-anak** bekerja dalam beberapa cara:

- **Komposisi.** Widget induk membungkus anaknya lewat properti `child` (satu anak, misalnya `Card`, `Padding`, dan `Material`) atau `children` (banyak anak, misalnya `Row`, `Column`, dan `GridView`). Tampilan kompleks dibuat dengan menyusun widget-widget kecil, bukan satu widget besar.
- **Data mengalir dari induk ke anak lewat konstruktor.** `MyHomePage` memberi data ke `InfoCard` dengan `InfoCard(title: 'NPM', content: npm)`, dan memberi satu objek `ItemHomepage` ke setiap `ItemCard`. Ke arah sebaliknya (anak ke induk), komunikasi dilakukan lewat *callback*, seperti `onTap` pada `InkWell`.
- **Aturan tata letak:** *constraints go down, sizes go up, parent sets position*[^2]. Induk memberi batasan ukuran (lebar dan tinggi minimum dan maksimum) kepada anak, anak memilih ukurannya di dalam batasan itu lalu melaporkannya ke atas, dan induklah yang menentukan posisi anak. Karena itu `GridView.count` di dalam `Column` memerlukan `shrinkWrap: true`, supaya ia tidak meminta tinggi tak terbatas dari induknya.
- **Induk mewariskan konteks ke seluruh keturunannya.** Tema dari `MaterialApp` bisa dibaca oleh widget mana pun di bawahnya, misalnya `Theme.of(context)` pada `AppBar`.

Di balik layar, Flutter sebenarnya memelihara tiga pohon: pohon widget (konfigurasi yang ringan dan tidak berubah), pohon *element* (objek yang hidup dan menyimpan posisi widget, itulah `BuildContext`), dan pohon *render object* (yang menghitung ukuran dan menggambar ke layar). Ketika tampilan perlu berubah, Flutter membangun ulang widget yang terdampak, dan karena widget murah dibuat, proses ini cepat.

> 2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!

**Widget bawaan Flutter yang dipakai:**

| Widget | Fungsinya di proyek ini |
|---|---|
| `MaterialApp` | Widget akar aplikasi. Mengatur judul, tema (`ThemeData`), dan halaman awal (`home`) |
| `Scaffold` | Kerangka dasar satu halaman: menyediakan tempat untuk `appBar` dan `body`, serta menjadi tempat `SnackBar` ditampilkan |
| `AppBar` | Bar atas halaman berisi judul `MyPortfolio` dengan warna utama navy |
| `SingleChildScrollView` | Membuat isi halaman bisa digulir, supaya enam kartu menu tidak terpotong di layar kecil |
| `Padding` | Memberi jarak di sekeliling isi halaman, di sekitar teks sambutan, dan di antara ikon dan teks pada kartu menu |
| `Column` | Menyusun anak-anaknya secara vertikal: susunan halaman, isi `InfoCard`, dan isi `ItemCard` |
| `Row` | Menyusun tiga `InfoCard` secara horizontal dan sejajar |
| `Center` | Memusatkan isinya, dipakai untuk bagian sambutan dan isi kartu menu |
| `SizedBox` | Kotak kosong berukuran tetap, dipakai sebagai jarak antar-elemen |
| `Text` | Menampilkan teks: judul, isi kartu info, tulisan sambutan, nama tombol, dan pesan SnackBar |
| `Card` | Kartu Material dengan bayangan tipis, dipakai sebagai wadah `InfoCard` |
| `Container` | Kotak serbaguna yang dipakai untuk mengatur lebar (`MediaQuery` dibagi 3,5) dan *padding* isi kartu |
| `GridView.count` | Kisi dengan jumlah kolom tetap (3 kolom), tempat enam `ItemCard` ditata dua baris |
| `Material` | Permukaan Material yang membawa warna latar dan sudut membulat kartu menu (`color: item.color`) |
| `InkWell` | Membuat kartu menu bisa disentuh, dengan efek percikan (*ripple*) dan penangan `onTap` |
| `Icon` | Menampilkan ikon pada setiap kartu menu |
| `SnackBar` | Pesan singkat di bawah layar saat kartu ditekan, ditampilkan lewat `ScaffoldMessenger` |

**Widget buatan sendiri (semuanya `StatelessWidget`):**

| Widget | Fungsinya |
|---|---|
| `MyApp` | Akar aplikasi, mengembalikan `MaterialApp` dengan tema |
| `MyHomePage` | Halaman utama yang merakit kartu info, teks sambutan, dan kisi menu |
| `InfoCard` | Kartu informasi yang dipakai ulang untuk NPM, Name, dan Class |
| `ItemCard` | Kartu tombol menu yang dipakai ulang untuk enam menu |

Selain itu ada dua kelas pendukung yang bukan widget: `ItemHomepage` (model data berisi nama, ikon, dan warna sebuah menu) dan `AppColors` (kumpulan konstanta warna).

> 3. Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!

`MaterialApp` adalah widget yang menyiapkan lingkungan aplikasi bergaya **Material Design**[^3]. Ia membungkus berbagai pengaturan tingkat aplikasi: judul aplikasi (`title`), tema (`theme`), halaman awal (`home`), serta pengelolaan navigasi antarhalaman (*routes* dan `Navigator`). Di baliknya, `MaterialApp` juga menyediakan layanan yang dipakai widget-widget di bawahnya, di antaranya `Theme`, `Navigator`, lokalisasi, dan `ScaffoldMessenger` (serta `MediaQuery` melalui `WidgetsApp` di dalamnya).

Di proyek saya, `MaterialApp` dipakai untuk:

- **menentukan tema**: `ColorScheme.fromSeed` dengan `seedColor` navy situs saya, warna sekunder oranye, `scaffoldBackgroundColor` krem, dan `useMaterial3: true`;
- **menentukan halaman awal**: `home: MyHomePage()`;
- **menyediakan `ScaffoldMessenger`**, yang membuat `ScaffoldMessenger.of(context).showSnackBar(...)` di `ItemCard` bisa bekerja.

Alasan `MaterialApp` umumnya menjadi *root widget*:

1. **Satu tempat untuk konfigurasi global.** Tema, judul, dan navigasi cukup diatur sekali di akar, lalu diwarisi seluruh widget di bawahnya. Mengubah palet warna cukup mengubah `ThemeData`.
2. **Banyak widget Material membutuhkannya.** `Scaffold`, `AppBar`, `InkWell`, dan `SnackBar` bergantung pada ancestor seperti `Theme`, `MediaQuery`, dan `ScaffoldMessenger`. Tanpa `MaterialApp` di atasnya, widget-widget itu biasanya melempar error karena tidak menemukan ancestor yang dibutuhkan.
3. **Konsistensi tampilan.** Seluruh halaman memakai bahasa visual yang sama dengan gaya Material Design.

Perlu dicatat bahwa `MaterialApp` bukan satu-satunya pilihan. Untuk gaya iOS ada `CupertinoApp`, dan ada juga `WidgetsApp` yang lebih dasar. Tetapi untuk aplikasi bergaya Material seperti ini, `MaterialApp` adalah pilihan yang paling lazim.

> 4. Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?

**StatelessWidget** adalah widget yang **tidak memiliki state yang berubah**. Tampilannya sepenuhnya ditentukan oleh nilai yang diberikan lewat konstruktor dan oleh *context* tempatnya berada. Semua field-nya bersifat `final`, dan method `build`-nya hanya dipanggil ketika induknya membangun ulang atau ketika ancestor yang ia andalkan (misalnya tema) berubah.

**StatefulWidget** adalah widget yang **memiliki objek `State` terpisah** yang hidup lebih lama daripada widget-nya. Data yang bisa berubah disimpan di objek `State` itu. Ketika data berubah, kita memanggil `setState()`, dan Flutter membangun ulang widget tersebut dengan data terbaru. Objek `State` juga punya siklus hidup (`initState`, `dispose`) untuk menyiapkan dan membersihkan sumber daya.

| Aspek | StatelessWidget | StatefulWidget |
|---|---|---|
| State yang berubah | Tidak ada | Ada, disimpan di objek `State` |
| Pembangunan ulang | Saat induk atau ancestor berubah | Juga saat `setState()` dipanggil |
| Struktur kode | Satu kelas | Dua kelas (widget dan `State`) |
| Siklus hidup | Hanya `build` | `initState`, `build`, `dispose`, dan lainnya |

**Kapan memilih yang mana:**

- Pilih **StatelessWidget** untuk tampilan yang tetap atau hanya bergantung pada data yang diberikan induknya. Di proyek ini, `MyApp`, `MyHomePage`, `InfoCard`, dan `ItemCard` semuanya `StatelessWidget`, karena data identitas dan daftar menunya tetap.
- Pilih **StatefulWidget** ketika widget itu sendiri harus mengingat data yang berubah selama aplikasi berjalan, misalnya penghitung angka, isian form, tab yang sedang aktif, atau animasi.

Contohnya ada di tutorial: halaman bawaan Flutter (`MyHomePage` dengan variabel `_counter`) adalah `StatefulWidget` karena angkanya berubah saat tombol `+` ditekan. Saat saya mengubah halaman menu menjadi tampilan statis, kelas `_MyHomePageState` dibuang dan halaman itu menjadi `StatelessWidget`, karena tidak ada lagi state yang perlu dikelola. Perlu diingat bahwa `ItemCard` tidak butuh state sendiri untuk menampilkan `SnackBar`, sebab `ScaffoldMessenger` yang memegang keadaan SnackBar-nya. Kalau nanti halaman ini mengambil data dari API Django atau punya form tambah data, halaman terkait akan perlu `StatefulWidget` atau pendekatan pengelolaan state lain.

> 5. Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?

**BuildContext**[^4] adalah *handle* (pegangan) ke **posisi sebuah widget di dalam widget tree**. Secara internal, setiap widget punya satu objek *element* di pohon element, dan `BuildContext` adalah antarmuka ke element itu. Setiap widget punya `BuildContext`-nya sendiri.

Pentingnya, `BuildContext` memungkinkan sebuah widget **melihat ke atas pohon untuk mencari ancestor** dan membaca data yang disediakannya, tanpa data itu harus dilewatkan lewat konstruktor di setiap tingkat. Method `build` menerimanya sebagai parameter: `Widget build(BuildContext context)`.

Penggunaannya di proyek saya:

- `Theme.of(context).colorScheme.primary` pada `AppBar` di `MyHomePage` mengambil warna utama dari tema yang diatur `MaterialApp`.
- `MediaQuery.of(context).size.width / 3.5` pada `InfoCard` mengambil lebar layar, sehingga tiga kartu selalu muat berjajar. Karena memanggil `MediaQuery.of(context)`, widget ini otomatis dibangun ulang ketika ukuran layar berubah.
- `ScaffoldMessenger.of(context).showSnackBar(...)` pada `onTap` di `ItemCard` mencari `ScaffoldMessenger` terdekat di atasnya (yang disediakan `MaterialApp`) untuk menampilkan SnackBar.

Dua hal yang perlu diperhatikan: pertama, `context` milik sebuah `build` merujuk ke posisi widget itu sendiri, bukan ke widget yang dikembalikannya, sehingga pencarian ke atas dimulai dari widget tersebut. Kedua, `context` sebaiknya tidak dipakai sembarangan setelah proses asinkron (`await`), karena widget-nya bisa saja sudah dilepas dari pohon.

> 6. Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?

Menurut dokumentasi resmi Flutter[^5], ada tiga tingkat pembaruan:

| | Yang dilakukan | State aplikasi |
|---|---|---|
| **Hot reload** | Memasukkan kode yang berubah ke Dart VM (atau browser) yang sedang berjalan, lalu membangun ulang widget tree. Tidak menjalankan ulang `main()` maupun `initState()` | **Tetap** |
| **Hot restart** | Memuat kode yang berubah lalu memulai ulang aplikasi dari awal | **Hilang** |
| **Full restart** | Memulai ulang aplikasi (Android, iOS, atau web) sambil mengompilasi ulang kode native. Di web, ini juga memulai ulang Dart Development Compiler. Dilakukan dengan menghentikan lalu menjalankan ulang aplikasi | **Hilang** |

Hot reload cepat (hitungan detik) dan mempertahankan state, jadi sangat berguna untuk mencoba-coba tampilan. Misalnya ketika saya mengubah warna kartu menu, hasilnya terlihat tanpa harus kehilangan posisi halaman. Fitur ini hanya bekerja pada aplikasi mode debug.

**Kapan hot reload tidak cukup:**

- **Perubahan pada `main()` atau `initState()`**, karena keduanya tidak dijalankan ulang saat hot reload. Perubahannya baru terlihat setelah hot restart.
- **Perubahan nilai awal variabel global dan field `static`**, karena field tersebut diinisialisasi sekali saja dan tidak diinisialisasi ulang oleh hot reload.
- **Perubahan tipe tertentu**, seperti mengubah `enum` menjadi kelas biasa atau sebaliknya, dan mengubah deklarasi tipe generik.
- **Perubahan kode native** (Kotlin, Java, Swift, Objective-C), yang menuntut full restart karena kode native harus dikompilasi ulang.
- **Keadaan aplikasi yang sudah tidak konsisten** dengan kode baru, atau aplikasi yang sempat mati atau ditutup sistem, sehingga hasil hot reload tidak bisa dipercaya.
- **Penambahan dependensi atau aset baru di `pubspec.yaml`** juga pada praktiknya mengharuskan aplikasi dijalankan ulang sepenuhnya.

Dalam pengerjaan ini, saya menjalankan aplikasi di browser lewat `flutter run -d web-server`. Karena laptop saya hanya memiliki RAM 4 GB, saya biasanya menghentikan aplikasi saat mengedit kode dan menjalankannya lagi setelah satu bagian selesai, yang secara praktik setara dengan full restart. Jadi untuk proyek ini saya tidak mengandalkan hot reload selama pengerjaan.

## AI Disclosure

Dalam proyek Flutter ini saya memakai Claude (Anthropic) sebagai pemandu belajar, karena Flutter dan Dart benar-benar baru bagi saya, sehingga ada banyak penyesuaian yang perlu saya tanyakan. Strategi prompting saya adalah meminta penjelasan satu langkah kecil per giliran beserta alasan di balik setiap barisnya, lalu menjalankan sendiri setiap langkah itu di terminal dan VS Code dan melaporkan hasilnya lewat output terminal maupun screenshot, sehingga arahan berikutnya mengikuti kondisi nyata di komputer saya dan bukan contoh umum. AI membantu menuliskan kerangka kode berdasarkan materi tutorial dan menyesuaikannya dengan kebutuhan tugas, yaitu atribut warna pada ItemHomepage, enam kartu menu, dan penyelarasan tema, sedangkan arah dan isinya saya yang menentukan, seperti misalnya data identitas, pilihan enam tombol yang mewakili Experience, Education, dan Proyek dari situs web saya, penggunaan palet warna situs web saya sendiri sebagai dasar tampilan, keputusan menjalankan aplikasi di browser tanpa Android Studio. Kode yang diberikan tidak saya terima begitu saja, saya memverifikasinya dengan flutter analyze, mencoba setiap kartu beserta SnackBar-nya di browser, dan melaporkan kejanggalan yang saya temui. Dari proses ini keterbatasan AI terlihat jelas pada hal yang bergantung pada kondisi lokal dan visual, ia tidak bisa melihat apakah kombinasi warna enam kartu atau nama lengkap yang panjang sudah enak dipandang di layar. Penilaian akhir atas kerapian tampilan itu saya lakukan sendiri lewat hasil di browser.

## Installation and Running

### Requirements

- Flutter SDK (channel stable). Diuji dengan Flutter 3.47.9 dan Dart 3.13.7
- Git
- Browser (Chrome atau Edge)

Android Studio dan emulator **tidak diperlukan** untuk menjalankan aplikasi ini di browser.

### Menjalankan aplikasi

Clone repositori ini
```bash
git clone https://github.com/msystemctrl/myportofolio_mobile.git
cd myportofolio_mobile
```

Unduh dependensi dan periksa kode
```bash
flutter pub get
flutter analyze
```

Jalankan di browser
```bash
flutter run -d chrome
```

Untuk perangkat dengan RAM terbatas, sajikan aplikasi sebagai server web lokal lalu buka alamatnya di browser yang sudah terbuka:
```bash
flutter run -d web-server --web-port 8080
```
Lalu buka `http://localhost:8080`. Tekan `q` di terminal untuk menghentikan aplikasi.

### Catatan `flutter doctor`

Pada komputer pengembangan saya, bagian **Android toolchain** dan **Visual Studio** bertanda silang karena Android Studio tidak dipasang dan aplikasi desktop Windows tidak dibangun. Itu tidak memengaruhi aplikasi web ini.

## Referensi

- https://docs.flutter.dev/get-started/fundamentals/widgets
- https://docs.flutter.dev/ui/layout/constraints
- https://api.flutter.dev/flutter/material/MaterialApp-class.html
- https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html
- https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
- https://api.flutter.dev/flutter/widgets/BuildContext-class.html
- https://api.flutter.dev/flutter/material/ScaffoldMessenger-class.html
- https://docs.flutter.dev/tools/hot-reload

[^1]: Widget tree: struktur bertingkat yang terbentuk ketika widget disusun di dalam widget lain, dimulai dari satu widget akar.
[^2]: Aturan tata letak Flutter: batasan ukuran (*constraints*) diturunkan dari induk ke anak, ukuran dilaporkan dari anak ke induk, dan induk menentukan posisi anak.
[^3]: Material Design: sistem desain buatan Google yang menjadi dasar komponen antarmuka bawaan Flutter seperti `Scaffold`, `AppBar`, dan `SnackBar`.
[^4]: BuildContext: antarmuka ke posisi sebuah widget di widget tree, yang dipakai untuk mencari widget ancestor dan data yang disediakannya.
[^5]: Dokumentasi hot reload Flutter: https://docs.flutter.dev/tools/hot-reload
