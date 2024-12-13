-- Buat database
CREATE DATABASE akademik_db;
USE akademik_db;

-- Tabel user
CREATE TABLE user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'dosen', 'mahasiswa') NOT NULL
);

-- Tabel mahasiswa
CREATE TABLE mahasiswa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT,
    nama VARCHAR(100) NOT NULL,
    npm VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100),
    alamat TEXT,
    FOREIGN KEY (id_user) REFERENCES user(id) ON DELETE CASCADE
);

-- Tabel dosen
CREATE TABLE dosen (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT,
    nama VARCHAR(100) NOT NULL,
    nidn VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100),
    jabatan VARCHAR(50),
    FOREIGN KEY (id_user) REFERENCES user(id) ON DELETE CASCADE
);

-- Tabel mata_kuliah
CREATE TABLE mata_kuliah (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_dosen INT,
    kode_matakul VARCHAR(20) UNIQUE NOT NULL,
    nama_matkul VARCHAR(100) NOT NULL,
    sks INT NOT NULL,
    FOREIGN KEY (id_dosen) REFERENCES dosen(id) ON DELETE SET NULL
);

-- Tabel jadwal
CREATE TABLE jadwal (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_matakuliah INT,
    ruangan VARCHAR(20) NOT NULL,
    hari ENUM('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu') NOT NULL,
    jam VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_matakuliah) REFERENCES mata_kuliah(id) ON DELETE CASCADE
);

-- Tabel nilai
CREATE TABLE nilai (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_mahasiswa INT,
    id_matakuliah INT,
    nilai DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (id_mahasiswa) REFERENCES mahasiswa(id) ON DELETE CASCADE,
    FOREIGN KEY (id_matakuliah) REFERENCES mata_kuliah(id) ON DELETE CASCADE
);

-- Tabel absensi
CREATE TABLE absensi (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_mahasiswa INT,
    id_matakuliah INT,
    tanggal DATE NOT NULL,
    status ENUM('Hadir', 'Izin', 'Sakit', 'Alpa') NOT NULL,
    pertemuan INT,
    FOREIGN KEY (id_mahasiswa) REFERENCES mahasiswa(id) ON DELETE CASCADE,
    FOREIGN KEY (id_matakuliah) REFERENCES mata_kuliah(id) ON DELETE CASCADE
);

-- Tabel KRS
CREATE TABLE krs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_mahasiswa INT,
    id_matakuliah INT,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    semester VARCHAR(20),
    tahun_ajaran VARCHAR(20),
    FOREIGN KEY (id_mahasiswa) REFERENCES mahasiswa(id) ON DELETE CASCADE,
    FOREIGN KEY (id_matakuliah) REFERENCES mata_kuliah(id) ON DELETE CASCADE
);

-- Insert data admin default
INSERT INTO user (username, password, role) VALUES ('admin', MD5('admin123'), 'admin');

-- Insert beberapa data mahasiswa untuk testing
INSERT INTO mahasiswa (nama, npm, email, alamat) VALUES 
('John Doe', '2024001', 'john@example.com', 'Jakarta'),
('Jane Smith', '2024002', 'jane@example.com', 'Bandung'); 