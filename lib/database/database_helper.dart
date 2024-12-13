import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static ConnectionSettings? _settings;

  static Future<void> _initSettings() async {
    _settings ??= ConnectionSettings(
      host: '10.0.2.2',
      port: 3306,
      user: 'root',
      db: 'akademik_db',
      timeout: Duration(seconds: 30),
    );
  }

  static Future<MySqlConnection> getConnection() async {
    try {
      await _initSettings();
      final conn = await MySqlConnection.connect(_settings!);
      print('Database connected successfully');
      return conn;
    } catch (e) {
      print('Error koneksi database: $e');
      throw Exception('Tidak dapat terhubung ke database: $e');
    }
  }
} 