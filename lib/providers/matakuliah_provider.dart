import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../database/database_helper.dart';
import '../models/mata_kuliah.dart';

class MataKuliahProvider with ChangeNotifier {
  List<MataKuliah> _mataKuliahList = [];
  List<MataKuliah> get mataKuliahList => _mataKuliahList;

  Future<void> getAllMataKuliah() async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT mk.*, d.nama as nama_dosen 
        FROM mata_kuliah mk 
        LEFT JOIN dosen d ON mk.id_dosen = d.id
      ''');

      _mataKuliahList = results.map((row) => MataKuliah.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting mata kuliah: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<bool> addMataKuliah(String kode, String nama, int sks, int idDosen) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query(
        'INSERT INTO mata_kuliah (kode_matakul, nama_matkul, sks, id_dosen) VALUES (?, ?, ?, ?)',
        [kode, nama, sks, idDosen]
      );
      await getAllMataKuliah();
      return true;
    } catch (e) {
      print('Error adding mata kuliah: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> updateMataKuliah(int id, String kode, String nama, int sks, int idDosen) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query(
        'UPDATE mata_kuliah SET kode_matakul = ?, nama_matkul = ?, sks = ?, id_dosen = ? WHERE id = ?',
        [kode, nama, sks, idDosen, id]
      );
      await getAllMataKuliah();
      return true;
    } catch (e) {
      print('Error updating mata kuliah: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> deleteMataKuliah(int id) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query('DELETE FROM mata_kuliah WHERE id = ?', [id]);
      await getAllMataKuliah();
      return true;
    } catch (e) {
      print('Error deleting mata kuliah: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<void> getMataKuliahByDosen(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT mk.*, d.nama as nama_dosen 
        FROM mata_kuliah mk 
        JOIN dosen d ON mk.id_dosen = d.id
        WHERE d.id_user = ?
      ''', [userId]);

      _mataKuliahList = results.map((row) => MataKuliah.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting mata kuliah by dosen: $e');
    } finally {
      await conn?.close();
    }
  }
} 