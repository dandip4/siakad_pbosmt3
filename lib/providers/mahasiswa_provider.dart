import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../database/database_helper.dart';
import '../models/mahasiswa.dart';

class MahasiswaProvider with ChangeNotifier {
  List<Mahasiswa> _mahasiswaList = [];
  List<Mahasiswa> get mahasiswaList => _mahasiswaList;

  Future<void> getAllMahasiswa() async {
    try {
      final conn = await DatabaseHelper.getConnection();
      print('Executing mahasiswa query...');
      var results = await conn.query('SELECT * FROM mahasiswa');
      print('Query results: ${results.length} rows');

      _mahasiswaList = [];  // Reset list
      
      for (var row in results) {
        try {
          print('Processing row: ${row.fields}');
          final mahasiswa = Mahasiswa.fromMap(row.fields);
          print('Processed mahasiswa: ${mahasiswa.nama}');
          _mahasiswaList.add(mahasiswa);
        } catch (e) {
          print('Error processing row: $e');
          print('Row data: ${row.fields}');
        }
      }
      
      await conn.close();
      print('Final mahasiswa list: ${_mahasiswaList.length} items');
      notifyListeners();
    } catch (e) {
      print('Error getting mahasiswa: $e');
    }
  }

  Future<bool> addMahasiswa(
    String npm, 
    String nama, 
    String email, 
    String alamat,
    String password,
  ) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      
      // Create user first
      var userResult = await conn.query(
        'INSERT INTO user (username, password, role) VALUES (?, MD5(?), ?)',
        [npm, password, 'mahasiswa']
      );
      int userId = userResult.insertId!;

      // Then create mahasiswa
      await conn.query(
        'INSERT INTO mahasiswa (id_user, npm, nama, email, alamat) VALUES (?, ?, ?, ?, ?)',
        [userId, npm, nama, email, alamat]
      );
      
      await getAllMahasiswa();
      return true;
    } catch (e) {
      print('Error adding mahasiswa: $e');
      return false;
    }
  }

  Future<bool> updateMahasiswa(int id, String nama, String npm, String email, String alamat) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      await conn.query(
        'UPDATE mahasiswa SET nama = ?, npm = ?, email = ?, alamat = ? WHERE id = ?',
        [nama, npm, email, alamat, id]
      );
      await conn.close();
      await getAllMahasiswa();
      return true;
    } catch (e) {
      print('Error updating mahasiswa: $e');
      return false;
    }
  }

  Future<bool> deleteMahasiswa(int id) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      await conn.query('DELETE FROM mahasiswa WHERE id = ?', [id]);
      await conn.close();
      await getAllMahasiswa();
      return true;
    } catch (e) {
      print('Error deleting mahasiswa: $e');
      return false;
    }
  }
} 