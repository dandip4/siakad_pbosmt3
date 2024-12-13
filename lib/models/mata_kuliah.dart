class MataKuliah {
  final int id;
  final int? idDosen;
  final String kodeMatkul;
  final String namaMatkul;
  final int sks;
  final String? namaDosen;

  MataKuliah({
    required this.id,
    this.idDosen,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.sks,
    this.namaDosen,
  });

  factory MataKuliah.fromMap(Map<String, dynamic> map) {
    return MataKuliah(
      id: map['id'],
      idDosen: map['id_dosen'],
      kodeMatkul: map['kode_matakul'],
      namaMatkul: map['nama_matkul'],
      sks: map['sks'],
      namaDosen: map['nama_dosen'],
    );
  }
} 