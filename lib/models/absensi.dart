import 'package:intl/intl.dart';

class Absensi {
  final int id;
  final int? idMahasiswa;
  final int? idMatakuliah;
  final String tanggal;
  final String status;
  final String? namaMahasiswa;
  final String? npm;
  final String? namaMatkul;
  final String? kodeMatkul;
  final int? pertemuan;
  final String? ruangan;
  final String? jamKuliah;

  Absensi({
    required this.id,
    this.idMahasiswa,
    this.idMatakuliah,
    required this.tanggal,
    required this.status,
    this.namaMahasiswa,
    this.npm,
    this.namaMatkul,
    this.kodeMatkul,
    this.pertemuan,
    this.ruangan,
    this.jamKuliah,
  });

  factory Absensi.fromMap(Map<String, dynamic> map) {
    return Absensi(
      id: map['id'],
      idMahasiswa: map['id_mahasiswa'],
      idMatakuliah: map['id_matakuliah'],
      tanggal: map['tanggal'] is DateTime 
          ? DateFormat('yyyy-MM-dd').format(map['tanggal']) 
          : map['tanggal'].toString(),
      status: map['status'],
      namaMahasiswa: map['nama_mahasiswa'],
      npm: map['npm'],
      namaMatkul: map['nama_matkul'],
      kodeMatkul: map['kode_matakul'],
      pertemuan: map['pertemuan'],
      ruangan: map['ruangan'],
      jamKuliah: map['jam'],
    );
  }
} 