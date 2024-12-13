import 'package:mysql1/mysql1.dart';
import 'database_interface.dart';

class DatabaseMobile implements DatabaseInterface {
  static DatabaseMobile? _instance;
  static MySqlConnection? _connection;
  static ConnectionSettings? _settings;

  DatabaseMobile._();

  static Future<DatabaseMobile> getInstance() async {
    _instance ??= DatabaseMobile._();
    _settings ??= ConnectionSettings(
      host: '10.0.2.2',
      port: 3306,
      user: 'root',
      db: 'akademik_db',
      timeout: Duration(seconds: 30),
    );
    return _instance!;
  }

  @override
  Future<MySqlConnection> getConnection() async {
    try {
      if (_connection == null || _connection!.isClosed) {
        _connection = await MySqlConnection.connect(_settings!);
        print('Database connected successfully');
      }
      return _connection!;
    } catch (e) {
      print('Error koneksi database: $e');
      throw Exception('Tidak dapat terhubung ke database: $e');
    }
  }

  @override
  Future<void> closeConnection() async {
    await _connection?.close();
    _connection = null;
  }
} 