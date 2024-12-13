class Dosen {
  final int id;
  final int idUser;
  final String nama;
  final String nidn;
  final String email;
  final String jabatan;

  Dosen({
    required this.id,
    required this.idUser,
    required this.nama,
    required this.nidn,
    required this.email,
    required this.jabatan,
  });

  factory Dosen.fromMap(Map<String, dynamic> map) {
    return Dosen(
      id: map['id'],
      idUser: map['id_user'],
      nama: map['nama'],
      nidn: map['nidn'],
      email: map['email'],
      jabatan: map['jabatan'],
    );
  }
} 