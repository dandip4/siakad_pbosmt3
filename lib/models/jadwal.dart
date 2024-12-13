class Jadwal {
  final int id;
  final int idMatakuliah;
  final String ruangan;
  final String hari;
  final String jam;
  final String? namaMatkul;
  final String? kodeMatkul;
  final String? namaDosen;
  final int? sks;

  Jadwal({
    required this.id,
    required this.idMatakuliah,
    required this.ruangan,
    required this.hari,
    required this.jam,
    this.namaMatkul,
    this.kodeMatkul,
    this.namaDosen,
    this.sks,
  });

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      idMatakuliah: map['id_matakuliah'],
      ruangan: map['ruangan'],
      hari: map['hari'],
      jam: map['jam'],
      namaMatkul: map['nama_matkul'],
      kodeMatkul: map['kode_matakul'],
      namaDosen: map['nama_dosen'],
      sks: map['sks'],
    );
  }
} 