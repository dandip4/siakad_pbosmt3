class User {
  final int id;
  final String username;
  final String password;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
    );
  }
} 