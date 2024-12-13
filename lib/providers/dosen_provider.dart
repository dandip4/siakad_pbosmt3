import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../database/database_helper.dart';
import '../models/dosen.dart';

class DosenProvider with ChangeNotifier {
  List<Dosen> _dosenList = [];
  List<Dosen> get dosenList => _dosenList;

  Future<void> getAllDosen() async {
    try {
      final conn = await DatabaseHelper.getConnection();
      print('Executing dosen query...');
      var results = await conn.query('SELECT * FROM dosen');
      print('Query results: ${results.length} rows');

      _dosenList = [];
      
      for (var row in results) {
        try {
          print('Processing row: ${row.fields}');
          final dosen = Dosen.fromMap(row.fields);
          print('Processed dosen: ${dosen.nama}');
          _dosenList.add(dosen);
        } catch (e) {
          print('Error processing row: $e');
          print('Row data: ${row.fields}');
        }
      }
      
      await conn.close();
      print('Final dosen list: ${_dosenList.length} items');
      notifyListeners();
    } catch (e) {
      print('Error getting dosen: $e');
    }
  }

  Future<bool> addDosen(String nama, String nidn, String email, String jabatan, int idUser) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      var result = await conn.query(
        'INSERT INTO dosen (nama, nidn, email, jabatan, id_user) VALUES (?, ?, ?, ?, ?)',
        [nama, nidn, email, jabatan, idUser]
      );
      await conn.close();
      await getAllDosen();
      return true;
    } catch (e) {
      print('Error adding dosen: $e');
      return false;
    }
  }

  Future<bool> updateDosen(int id, String nama, String nidn, String email, String jabatan) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query(
        'UPDATE dosen SET nama = ?, nidn = ?, email = ?, jabatan = ? WHERE id = ?',
        [nama, nidn, email, jabatan, id]
      );
      await getAllDosen();
      return true;
    } catch (e) {
      print('Error updating dosen: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> deleteDosen(int id) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      // Get user_id first
      var result = await conn.query(
        'SELECT id_user FROM dosen WHERE id = ?',
        [id]
      );
      
      if (result.isNotEmpty) {
        int userId = result.first['id_user'];
        
        // Delete dosen first (due to foreign key)
        await conn.query('DELETE FROM dosen WHERE id = ?', [id]);
        
        // Then delete user
        await conn.query('DELETE FROM user WHERE id = ?', [userId]);
      }
      
      await getAllDosen();
      return true;
    } catch (e) {
      print('Error deleting dosen: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }
} 