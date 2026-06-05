# ☕ Panduan Demo & Presentasi Aplikasi Dincoff

Dokumen ini disusun untuk memandu Anda saat melakukan presentasi dan demo aplikasi **Dincoff**. Panduan ini menjelaskan cara menunjukkan fitur secara langsung di UI (User Interface) aplikasi.

---

## 🗺️ Alur Umum Demo Aplikasi
Untuk presentasi yang mulus, disarankan mengikuti urutan demo berikut:
1. **Pendaftaran Akun Baru** (Registrasi User).
2. **Autentikasi Pengguna** (Login User biasa).
3. **Eksplorasi Katalog & Keranjang** (Melihat menu, menambah kuantitas, total harga).
4. **Proses Checkout & Pembayaran** (Reset keranjang).
5. **Manajemen Profil & Ganti Tema** (Theme Toggle).
6. **Autentikasi Admin** (Login Admin).
7. **Kelola Menu Kopi** (Tambah, Edit, Hapus kopi, & hitung total menu).
8. **Kelola Pengguna & Pesanan** (Melihat daftar user dan pesanan masuk).

---

## 🗄️ Bagian 1: SQLite Database Routes (9 Operasi)

Berikut adalah detail penjelasan cara mendemokan 9 rute database SQLite:

### 1. `insertCoffee(Coffee coffee)`
* **Kegunaan**: Menambahkan produk kopi baru ke dalam database SQLite.
* **Cara Demo saat Presentasi**:
  1. Login sebagai Admin menggunakan email `admin@dincoff.com` dan password `admin123`.
  2. Buka menu **Manage Coffee**.
  3. Klik tombol **Tambah Kopi (+)** di pojok kanan atas.
  4. Isi data kopi baru (Nama, Harga, Deskripsi, Kategori), lalu tekan **Save**.
  5. *Penjelasan*: "Saat menekan Save, aplikasi memanggil fungsi `insertCoffee` untuk menyimpan data produk secara permanen di SQLite."

### 2. `getAllCoffees()`
* **Kegunaan**: Mengambil seluruh daftar menu kopi untuk ditampilkan di aplikasi.
* **Cara Demo saat Presentasi**:
  1. Buka halaman utama (Home) atau masuk ke tab **Menu**.
  2. Tunjukkan daftar kopi yang tampil di layar.
  3. *Penjelasan*: "Daftar menu kopi yang Anda lihat di halaman ini diambil langsung dari SQLite menggunakan fungsi `getAllCoffees` saat aplikasi pertama kali dimuat."

### 3. `getCoffeeById(String id)`
* **Kegunaan**: Mengambil detail spesifik dari satu jenis kopi berdasarkan ID uniknya.
* **Cara Demo saat Presentasi**:
  1. Klik salah satu item kopi dari halaman utama untuk masuk ke halaman **Detail Kopi**.
  2. Tunjukkan informasi detail seperti deskripsi lengkap, rating, dan harga.
  3. *Penjelasan*: "Saat item kopi diklik, sistem dapat menggunakan ID kopi tersebut untuk membaca data detail spesifiknya melalui rute `getCoffeeById`."

### 4. `updateCoffee(Coffee coffee)`
* **Kegunaan**: Memperbarui detail informasi (nama, harga, deskripsi) produk kopi yang sudah ada.
* **Cara Demo saat Presentasi**:
  1. Di bawah akun Admin, masuk ke **Manage Coffee**.
  2. Pilih salah satu kopi, klik ikon **Edit (Pensil)**.
  3. Ubah harga atau deskripsinya, lalu tekan **Save**.
  4. Perhatikan perubahan harga yang langsung ter-update di daftar.
  5. *Penjelasan*: "Tombol simpan pada formulir edit memicu metode `updateCoffee` untuk memperbarui baris data kopi tersebut di SQLite."

### 5. `deleteCoffee(String id)`
* **Kegunaan**: Menghapus produk kopi secara permanen dari menu database.
* **Cara Demo saat Presentasi**:
  1. Di bawah akun Admin, masuk ke **Manage Coffee**.
  2. Tekan ikon **Tempat Sampah (Delete)** pada salah satu kopi yang ingin dihapus.
  3. Konfirmasikan penghapusan pada dialog yang muncul.
  4. Produk tersebut akan hilang dari daftar menu.
  5. *Penjelasan*: "Metode `deleteCoffee` dipanggil dengan mengirimkan ID kopi yang dipilih untuk dihapus dari tabel database."

### 6. `getCoffeeCount()`
* **Kegunaan**: Menghitung jumlah total produk kopi yang tersedia di menu database.
* **Cara Demo saat Presentasi**:
  1. Masuk ke halaman **Menu** (User) atau **Manage Coffee** (Admin).
  2. Tunjukkan teks status di bagian atas yang berbunyi seperti *"Showing X coffee items"*.
  3. *Penjelasan*: "Angka jumlah item tersebut dimuat secara dinamis menggunakan fungsi agregat SQLite `COUNT(*)` melalui `getCoffeeCount()`."

### 7. `getUserByEmail(String email)`
* **Kegunaan**: Mengambil data pengguna berdasarkan email untuk verifikasi login dan registrasi.
* **Cara Demo saat Presentasi**:
  1. Lakukan logout terlebih dahulu, lalu masuk ke halaman **Login**.
  2. Masukkan alamat email yang sudah terdaftar dan password, lalu klik **Login**.
  3. *Penjelasan*: "Sistem memanggil `getUserByEmail` untuk mencari apakah email tersebut ada di database SQLite. Jika ditemukan, sistem mencocokkan password-nya agar pengguna dapat masuk."

### 8. `getUserById(String id)`
* **Kegunaan**: Mengambil data detail pengguna berdasarkan ID pengguna.
* **Cara Demo saat Presentasi**:
  1. Login sebagai Admin, lalu buka halaman **View Orders** (Daftar Pesanan).
  2. Tunjukkan nama pemesan yang tercantum pada setiap kartu transaksi.
  3. *Penjelasan*: "Setiap data pesanan hanya menyimpan `userId`. Untuk menampilkan nama lengkap pembeli di dashboard admin, aplikasi memanggil `getUserById` menggunakan ID tersebut."

### 9. `getAllUsers()`
* **Kegunaan**: Mengambil seluruh daftar pengguna yang terdaftar dalam sistem.
* **Cara Demo saat Presentasi**:
  1. Login sebagai Admin, lalu buka halaman **Manage Users** (Kelola Pengguna).
  2. Tunjukkan daftar nama dan email pengguna terdaftar yang ditampilkan di layar.
  3. *Penjelasan*: "Daftar pengguna ini diambil secara keseluruhan dari tabel pengguna SQLite menggunakan rute `getAllUsers()`."

---

## ⚡ Bagian 2: Shared Preferences (7 Kunci Preferensi)

Shared Preferences menyimpan data ringan dalam bentuk key-value secara lokal pada perangkat untuk mempertahankan state aplikasi tanpa query database yang berat.

### 1. `isLoggedIn` (bool)
* **Kegunaan**: Menyimpan status login aktif pengguna (apakah sesi aktif atau tidak).
* **Cara Demo saat Presentasi**:
  1. Lakukan login, lalu tutup aplikasi sepenuhnya (close task).
  2. Buka kembali aplikasi Dincoff.
  3. Tunjukkan bahwa aplikasi langsung membuka halaman utama (Home) tanpa meminta login ulang.
  4. Klik **Logout** di halaman Profile, lalu tutup dan buka kembali. Aplikasi akan tertahan di halaman Login.
  5. *Penjelasan*: "Sesi login disimpan pada key `isLoggedIn`. Jika bernilai `true`, aplikasi otomatis melewatkan halaman login saat pertama kali dibuka."

### 2. `username` (String)
* **Kegunaan**: Menyimpan nama lengkap/tampilan pengguna aktif yang sedang login.
* **Cara Demo saat Presentasi**:
  1. Login dengan akun tertentu (contoh: "Fahmi").
  2. Buka halaman utama (Home) dan lihat tulisan selamat datang: *"Welcome, Fahmi"*.
  3. Masuk ke halaman **Profile**, nama "Fahmi" juga terpampang di bagian atas.
  4. *Penjelasan*: "Nama tampilan ini disimpan langsung di Shared Preferences dengan key `username` sewaktu login berhasil, sehingga aplikasi dapat memuatnya secara instan tanpa perlu query ulang ke database SQLite."

### 3. `userEmail` (String)
* **Kegunaan**: Menyimpan alamat email dari pengguna yang sedang masuk.
* **Cara Demo saat Presentasi**:
  1. Masuk ke halaman **Profile**.
  2. Tunjukkan alamat email yang tertulis tepat di bawah nama pengguna Anda.
  3. *Penjelasan*: "Alamat email ini dibaca dari Shared Preferences menggunakan key `userEmail` untuk memverifikasi identitas pengguna aktif."

### 4. `themeMode` (String)
* **Kegunaan**: Menyimpan preferensi tema antarmuka (Light Mode / Dark Mode) pilihan pengguna.
* **Cara Demo saat Presentasi**:
  1. Buka halaman **Profile**.
  2. Geser switch **Dark Mode** menjadi aktif. Seluruh tema aplikasi akan berubah menjadi gelap.
  3. Tutup aplikasi dan buka kembali. Tunjukkan bahwa tema aplikasi tetap gelap (tidak kembali terang).
  4. *Penjelasan*: "Status tema disimpan menggunakan key `themeMode`. Ketika aplikasi dibuka, ia membaca preferensi ini terlebih dahulu agar tampilan konsisten dengan pilihan pengguna."

### 5. `cartTotal` (double)
* **Kegunaan**: Menyimpan total harga akumulatif belanjaan di dalam keranjang belanja lokal.
* **Cara Demo saat Presentasi**:
  1. Tambahkan beberapa kopi ke keranjang belanja Anda.
  2. Masuk ke halaman **Keranjang (Cart)**, lalu klik **Checkout** dan lakukan pembayaran di **Payment Screen**.
  3. Setelah pembayaran dikonfirmasi sukses, tunjukkan bahwa keranjang belanja Anda kini kosong dan total belanja bernilai Rp 0.
  4. *Penjelasan*: "Saat pembayaran sukses, sistem memanggil `PrefsHelper.setCartTotal(0)` untuk merestart nominal keranjang belanja pengguna di Shared Preferences."

### 6. `appVersion` (String)
* **Kegunaan**: Menyimpan informasi versi aplikasi yang sedang berjalan untuk keperluan pelaporan atau debugging.
* **Cara Demo saat Presentasi**:
  1. Buka halaman **Profile**.
  2. Gulir ke bawah dan tunjukkan teks versi di layar: *“App Version: X.X.X”*.
  3. *Penjelasan*: "Sistem mengambil data versi build aplikasi secara dinamis melalui package platform, lalu mencatatnya di Shared Preferences dengan key `appVersion` untuk ditampilkan di halaman profil."

### 7. `lastSyncTime` (String)
* **Kegunaan**: Menyimpan waktu terakhir kali data lokal berhasil disinkronisasikan ke server eksternal/cloud.
* **Cara Demo saat Presentasi**:
  1. *Penjelasan*: "Variabel `lastSyncTime` disiapkan di Shared Preferences sebagai mekanisme pencatatan latar belakang (background sync). Ketika aplikasi terhubung ke internet, ia akan mencatat waktu sinkronisasi menu kopi lokal ke server cloud, sehingga sistem tahu kapan harus me-refresh data dan menjaga agar aplikasi tetap responsif tanpa sering-sering meminta request server."

---

## 💡 Tips Sukses Presentasi
* **Persiapan Awal**: Sebelum presentasi dimulai, pastikan database SQLite telah terisi dengan beberapa menu awal agar demo `getAllCoffees` langsung memukau dosen/penguji.
* **Tekankan Keunggulan**: Sampaikan bahwa penggunaan SQLite membuat aplikasi dapat menyimpan data kompleks (relasional) secara kokoh, sedangkan Shared Preferences menjaga agar data konfigurasi ringan dapat dimuat secara instan tanpa membebani performa aplikasi.
