# Laporan Penilaian Mandiri (Assessment Report) - Dincoff ☕

Dokumen ini berisi verifikasi pemenuhan syarat teknis untuk proyek aplikasi **Dincoff**.

---

## 📊 Ringkasan Pemenuhan Syarat

| Kriteria Syarat | Kebutuhan Minimum | Realisasi Proyek | Status |
| :--- | :---: | :---: | :---: |
| **Media Penyimpanan (Storage)** | SQLite & Shared Preferences | Terimplementasi Keduanya | **TERPENUHI** |
| **Rute/Operasi SQLite** | Minimal 8 | **26 Operasi** | **TERPENUHI** |
| **Shared Preferences Keys** | Minimal 8 | **12 Variabel/Kunci** | **TERPENUHI** |

---

## 🔍 Detail Pemeriksaan Syarat

### 1. Media Penyimpanan (Storage)
Proyek menggunakan dua jenis penyimpanan lokal:
* **SQLite (Struktur Data Relasional)**: Digunakan untuk menyimpan menu kopi, daftar pengguna (user), pesanan (orders), dan item keranjang belanja (cart).
* **Shared Preferences (Penyimpanan Key-Value Ringan)**: Digunakan untuk menyimpan sesi login pengguna, preferensi tema, bahasa, notifikasi, dan data total keranjang.

---

### 2. Rute/Operasi SQLite (Realisasi: 26 Operasi)
Seluruh operasi SQLite didefinisikan secara rapi di dalam berkas [db_helper.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/helpers/db_helper.dart):

| No | Nama Fungsi/Operasi | Deskripsi / Fungsi |
|:--:| :--- | :--- |
| 1 | `insertCoffee(Coffee coffee)` | Menambahkan produk kopi baru ke database. |
| 2 | `getAllCoffees()` | Mengambil seluruh data menu kopi. |
| 3 | `getCoffeeById(String id)` | Mengambil data menu kopi spesifik berdasarkan ID. |
| 4 | `updateCoffee(Coffee coffee)` | Memperbarui detail produk kopi yang sudah ada. |
| 5 | `deleteCoffee(String id)` | Menghapus produk kopi dari menu database. |
| 6 | `getCoffeeCount()` | Menghitung jumlah total produk kopi yang tersedia. |
| 7 | `getCoffeesByType(String type)` | Mengambil daftar produk kopi berdasarkan kategori/tipe. |
| 8 | `getTopRatedCoffees()` | Mengambil produk kopi terbaik berdasarkan rating tertinggi. |
| 9 | `searchCoffeeByName(String name)`| Mencari menu kopi berdasarkan pencocokan nama. |
| 10| `getCoffeesByPriceRange(...)` | Memfilter kopi berdasarkan rentang harga tertentu. |
| 11| `batchInsertCoffees(...)` | Memasukkan banyak data kopi sekaligus secara bersamaan. |
| 12| `deleteAllCoffees()` | Menghapus seluruh data menu kopi. |
| 13| `insertUser(...)` | Menyimpan data pendaftaran akun baru (register). |
| 14| `getUserByEmail(String email)` | Mengambil data pengguna berdasarkan alamat email (login). |
| 15| `getUserById(String id)` | Mengambil data detail pengguna berdasarkan ID. |
| 16| `getAllUsers()` | Mengambil semua daftar pengguna terdaftar. |
| 17| `deleteUser(String id)` | Menghapus akun pengguna tertentu. |
| 18| `emailExists(String email)` | Memeriksa ketersediaan email sebelum registrasi. |
| 19| `insertOrder(Order, String)` | Menyimpan transaksi pesanan baru (checkout). |
| 20| `getAllOrders()` | Mengambil seluruh daftar pesanan (untuk tampilan admin). |
| 21| `getOrdersByUserId(...)` | Mengambil riwayat pesanan milik pengguna tertentu. |
| 22| `updateOrderStatus(...)` | Memperbarui status pesanan (misal: konfirmasi pembayaran). |
| 23| `insertOrUpdateCartItem(...)`| Menyimpan atau mengupdate item di keranjang belanja. |
| 24| `getAllCartItems()` | Mengambil seluruh item belanja yang ada di keranjang. |
| 25| `deleteCartItem(String id)` | Menghapus item tertentu dari keranjang belanja. |
| 26| `deleteAllCartItems()` | Mengosongkan keranjang belanja (setelah checkout). |

---

### 3. Shared Preferences (Realisasi: 12 Kunci Preferensi)
Didefinisikan dalam berkas [prefs_helper.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/helpers/prefs_helper.dart), berikut adalah kunci-kunci preferensi yang digunakan:

1. `isLoggedIn` (`bool`): Status login aktif pengguna.
2. `userRole` (`String`): Peran pengguna aktif (`admin` atau `user`).
3. `username` (`String`): Nama lengkap/tampilan pengguna yang masuk.
4. `userEmail` (`String`): Email pengguna yang masuk.
5. `themeMode` (`String`): Preferensi tema antarmuka (`light` atau `dark`).
6. `lastLoginTime` (`String`): Catatan waktu login terakhir pengguna.
7. `language` (`String`): Preferensi bahasa aplikasi (`id`/`en`).
8. `notificationsEnabled` (`bool`): Pengaturan aktif/nonaktif notifikasi.
9. `appVersion` (`String`): Informasi versi aplikasi.
10. `lastSyncTime` (`String`): Waktu sinkronisasi data terakhir.
11. `userId` (`String`): ID pengguna aktif.
12. `cartTotal` (`double`): Total harga akumulatif belanjaan di keranjang.

---

## 📁 Lokasi File dan Penggunaannya

### 📂 File Pendefinisian
* **SQLite Helper**: [lib/helpers/db_helper.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/helpers/db_helper.dart)
* **Shared Preferences Helper**: [lib/helpers/prefs_helper.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/helpers/prefs_helper.dart)

### 📂 File Konsumsi/Penggunaan Layanan
1. [lib/providers/app_provider.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/providers/app_provider.dart)
   * Menggunakan `DBHelper` untuk mengelola state database.
   * Menggunakan `PrefsHelper` untuk sinkronisasi sesi pengguna aktif.
2. [lib/screens/login_screen.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/screens/login_screen.dart)
   * Menggunakan `PrefsHelper` untuk menyimpan sesi setelah autentikasi sukses.
3. [lib/screens/profile_screen.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/screens/profile_screen.dart)
   * Menggunakan `PrefsHelper` untuk menampilkan informasi profil pengguna dan menghapus preferensi saat keluar (logout).
4. [lib/screens/payment_screen.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/screens/payment_screen.dart)
   * Menggunakan `PrefsHelper` untuk memperbarui status keranjang belanja setelah konfirmasi bayar.
5. [lib/screens/cart_screen.dart](file:///c:/Users/fahmi/Downloads/assesmentPPBL/dincoff/dincoff/lib/screens/cart_screen.dart)
   * Menggunakan `PrefsHelper` untuk memverifikasi data checkout pengguna.
