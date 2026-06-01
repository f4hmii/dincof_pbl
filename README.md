# Dincoff ☕

Dincoff adalah aplikasi manajemen menu dan pemesanan kopi berbasis Flutter yang dirancang untuk mendukung operasional kafe (Point of Sale / Kasir). Proyek ini menggunakan database lokal SQLite via **sqflite** untuk platform mobile (Android/iOS) dan **sqflite_common_ffi** untuk platform desktop (Windows/macOS/Linux).

---

## 🚀 Panduan Memulai Setelah Kloning (Clone) Proyek

Jika Anda baru saja mengklon proyek ini dari GitHub, ikuti langkah-langkah di bawah ini untuk menyiapkan dan menjalankan aplikasi di komputer Anda.

### 📋 Prasyarat (Prerequisites)

Sebelum memulai, pastikan Anda telah menginstal komponen berikut:
1. **Flutter SDK** (Direkomendasikan Versi `3.19.0` atau yang lebih baru).
2. **Dart SDK** (Sudah termasuk di dalam paket Flutter SDK).
3. Emulator (Android/iOS) atau perangkat fisik yang sudah terhubung dengan USB Debugging aktif.
4. (Opsional untuk Windows Desktop) Visual Studio dengan beban kerja "Desktop development with C++" jika ingin menjalankan versi Windows.

---

### 🛠️ Langkah-Langkah Setup

#### 1. Masuk ke Direktori Proyek
Buka terminal/command prompt Anda, lalu masuk ke folder hasil klon proyek ini:
```bash
cd dincoff
```

#### 2. Unduh Dependensi (Package) Flutter
Jalankan perintah berikut untuk mengunduh semua paket yang digunakan dalam proyek ini (seperti `provider`, `sqflite`, `google_fonts`, dll.):
```bash
flutter pub get
```

#### 3. Verifikasi Lingkungan Flutter
Gunakan perintah ini untuk memastikan konfigurasi Flutter Anda sudah siap dan perangkat target terdeteksi:
```bash
flutter doctor
```
Pastikan tidak ada masalah kritis yang menghalangi Anda untuk menjalankan aplikasi.

---

### 💻 Menjalankan Aplikasi

Anda dapat menjalankan aplikasi di berbagai platform menggunakan perintah berikut:

#### Menjalankan di Perangkat Default / Terhubung
```bash
flutter run
```

#### Menjalankan di Windows Desktop
```bash
flutter run -d windows
```

#### Menjalankan di Emulator Android
```bash
flutter run -d android
```

#### Menjalankan di Chrome (Web)
```bash
flutter run -d chrome
```

---

## 📁 Struktur Dependensi Utama

Aplikasi ini menggunakan beberapa dependensi utama di `pubspec.yaml`:
* **`provider`**: Untuk manajemen state aplikasi (authentication, keranjang belanja, menu).
* **`sqflite` & `sqflite_common_ffi`**: Untuk basis data SQLite lokal yang mendukung platform mobile dan desktop.
* **`google_fonts`**: Untuk kustomisasi tipografi antarmuka.
* **`shared_preferences`**: Untuk menyimpan status sesi login pengguna.
* **`file_picker`**: Untuk memilih gambar produk kopi dari galeri komputer/ponsel.

---

## 💾 Catatan Penting Basis Data (Database)
* Di **Windows**, basis data akan disimpan secara lokal di folder dokumen pengguna: `C:\Users\<Username>\Dincoff\dincoff.db`.
* Di **Mobile (Android/iOS)**, basis data disimpan di direktori aplikasi internal standar.
* Skema basis data (tabel `users`, `coffees`, `orders`, dan `cartItems`) akan otomatis terbuat saat aplikasi pertama kali dijalankan.
