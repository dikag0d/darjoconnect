# Darjo Connect

Aplikasi layanan pelaporan dan informasi warga Sidoarjo. Warga dapat mengirim aduan, memantau progres penanganan, dan menerima pengumuman penting dari admin sesuai kategori.

---

## ✨ Fitur Utama

### 1. Pelaporan Aduan
- Warga dapat membuat laporan berdasarkan kategori:
  - 🔥 Kebakaran  
  - ⚡ Listrik / PLN  
  - 🛣️ Jalan Rusak  
  - 🚰 Air  
  - 🧹 Kesehatan
- Setiap laporan berisi:
  - Deskripsi  
  - Lokasi  
  - Foto  
  - Status (Diterima, Diproses, Selesai)  
  - Riwayat update dari admin  

---

### 2. Multi-Admin (Role Based Access)
Setiap admin hanya dapat mengakses laporan sesuai tugasnya:
- Admin Pemadam → kebakaran  
- Admin PLN → listrik  
- Admin Pemerintah → jalan rusak  
- Admin Kesehatan → ambulance, kecelakaan 

Admin menerima notifikasi saat ada laporan baru di kategorinya.

---

### 3. Pengumuman (Announcements)
Ketika warga menginputkan alamat yang sama 3 kali pada saat terjadi banjir,kemacetan,kebakaran maka sistem akan otomatis melaporkan pengumuman 
Pengumuman muncul pada dashboard warga.

---

### 4. Autentikasi Pengguna
- Login warga  
- Login admin  
- Registrasi akun  
- Token-based authentication  
- Validasi role (admin & user)  

---

## 🛠️ Teknologi yang Digunakan
- Flutter Dart (Frontend)
- PHP (Backend) 
- MySQL  (Database)  




