class Mahasiswa {
  final int id;
  final int? idUser;
  final String nama;
  final String npm;
  final String? email;
  final String? alamat;

  Mahasiswa({
    required this.id,
    this.idUser,
    required this.nama,
    required this.npm,
    this.email,
    this.alamat,
  });

  factory Mahasiswa.fromMap(Map<String, dynamic> map) {
    return Mahasiswa(
      id: map['id'],
      idUser: map['id_user'],
      nama: map['nama'].toString(),
      npm: map['npm'].toString(),
      email: map['email']?.toString(),
      alamat: map['alamat']?.toString(),
    );
  }
} 