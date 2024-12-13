import 'database_interface.dart';

class DatabaseWeb implements DatabaseInterface {
  @override
  Future<dynamic> getConnection() async {
    throw UnimplementedError('Web database not implemented yet');
  }

  @override
  Future<void> closeConnection() async {
    throw UnimplementedError('Web database not implemented yet');
  }
} 