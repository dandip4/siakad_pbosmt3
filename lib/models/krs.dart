class KRS {
  final int id;
  final int idMahasiswa;
  final int idMatakuliah;
  final String status;
  final String semester;
  final String tahunAjaran;
  final String? namaMatkul;
  final String? kodeMatkul;
  final int? sks;
  final String? namaDosen;
  final String? namaMahasiswa;
  final String? npm;

  KRS({
    required this.id,
    required this.idMahasiswa,
    required this.idMatakuliah,
    required this.status,
    required this.semester,
    required this.tahunAjaran,
    this.namaMatkul,
    this.kodeMatkul,
    this.sks,
    this.namaDosen,
    this.namaMahasiswa,
    this.npm,
  });

  factory KRS.fromMap(Map<String, dynamic> map) {
    return KRS(
      id: map['id'],
      idMahasiswa: map['id_mahasiswa'],
      idMatakuliah: map['id_matakuliah'],
      status: map['status'] ?? 'pending',
      semester: map['semester'] ?? '',
      tahunAjaran: map['tahun_ajaran'] ?? '',
      namaMatkul: map['nama_matkul'],
      kodeMatkul: map['kode_matakul'],
      sks: map['sks'],
      namaDosen: map['nama_dosen'],
      namaMahasiswa: map['nama_mahasiswa'],
      npm: map['npm'],
    );
  }
} 