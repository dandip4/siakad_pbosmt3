class Nilai {
  final int id;
  final int idMahasiswa;
  final int idMatakuliah;
  final double nilai;
  final String? namaMahasiswa;
  final String? npm;
  final String? namaMatkul;
  final String? kodeMatkul;
  final int? sks;
  final String semester;

  Nilai({
    required this.id,
    required this.idMahasiswa,
    required this.idMatakuliah,
    required this.nilai,
    this.namaMahasiswa,
    this.npm,
    this.namaMatkul,
    this.kodeMatkul,
    this.sks,
    required this.semester,
  });

  factory Nilai.fromMap(Map<String, dynamic> map) {
    return Nilai(
      id: map['id'],
      idMahasiswa: map['id_mahasiswa'],
      idMatakuliah: map['id_matakuliah'],
      nilai: map['nilai']?.toDouble() ?? 0.0,
      namaMahasiswa: map['nama_mahasiswa'],
      npm: map['npm'],
      namaMatkul: map['nama_matkul'],
      kodeMatkul: map['kode_matakul'],
      sks: map['sks'],
      semester: map['semester'] ?? '',
    );
  }
} 