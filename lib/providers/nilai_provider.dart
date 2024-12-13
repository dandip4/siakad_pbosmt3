import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../database/database_helper.dart';
import '../models/nilai.dart';

class NilaiProvider with ChangeNotifier {
  List<Nilai> _nilaiList = [];
  List<Nilai> get nilaiList => _nilaiList;

  // Ambil nilai untuk mahasiswa tertentu
  Future<void> getNilaiByMahasiswa(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT n.*, mk.nama_matkul, mk.kode_matakul, mk.sks, k.semester
        FROM nilai n
        JOIN mata_kuliah mk ON n.id_matakuliah = mk.id
        JOIN krs k ON n.id_matakuliah = k.id_matakuliah AND n.id_mahasiswa = k.id_mahasiswa
        JOIN mahasiswa m ON n.id_mahasiswa = m.id
        WHERE m.id_user = ?
        ORDER BY k.semester, mk.nama_matkul
      ''', [userId]);

      _nilaiList = results.map((row) => Nilai.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting nilai: $e');
    } finally {
      await conn?.close();
    }
  }

  // Ambil nilai untuk mata kuliah yang diajar dosen
  Future<void> getNilaiByDosen(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT n.*, m.nama as nama_mahasiswa, m.npm,
               mk.nama_matkul, mk.kode_matakul, mk.sks
        FROM nilai n
        JOIN mahasiswa m ON n.id_mahasiswa = m.id
        JOIN mata_kuliah mk ON n.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        WHERE d.id_user = ?
        ORDER BY mk.nama_matkul, m.nama
      ''', [userId]);

      _nilaiList = results.map((row) => Nilai.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting nilai by dosen: $e');
    } finally {
      await conn?.close();
    }
  }

  // Input atau update nilai
  Future<bool> addNilai(int idMahasiswa, int idMatakuliah, double nilai) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query(
        'INSERT INTO nilai (id_mahasiswa, id_matakuliah, nilai) VALUES (?, ?, ?)',
        [idMahasiswa, idMatakuliah, nilai]
      );
      
      // Refresh data
      await getNilaiByDosen(idMatakuliah);
      return true;
    } catch (e) {
      print('Error adding nilai: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  // Ambil daftar mahasiswa untuk input nilai
  Future<List<Map<String, dynamic>>> getMahasiswaByDosen(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT DISTINCT m.id, m.nama, m.npm, 
               mk.id as id_matakuliah, mk.nama_matkul, mk.kode_matakul
        FROM mahasiswa m
        JOIN krs k ON k.id_mahasiswa = m.id
        JOIN mata_kuliah mk ON k.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        WHERE d.id_user = ? AND k.status = 'approved'
        ORDER BY mk.nama_matkul, m.nama
      ''', [userId]);

      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('Error getting mahasiswa: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  // Tambahkan method ini
  Future<List<Map<String, dynamic>>> getMatakuliahDosen(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT mk.id, mk.nama_matkul, mk.kode_matakul
        FROM mata_kuliah mk
        JOIN dosen d ON mk.id_dosen = d.id
        WHERE d.id_user = ?
        ORDER BY mk.nama_matkul
      ''', [userId]);

      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('Error getting mata kuliah: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  // Tambahkan method ini juga
  Future<List<Map<String, dynamic>>> getMahasiswaByMatakuliah(int idMatakuliah) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT m.id, m.nama, m.npm
        FROM mahasiswa m
        JOIN krs k ON k.id_mahasiswa = m.id
        WHERE k.id_matakuliah = ? AND k.status = 'approved'
        ORDER BY m.nama
      ''', [idMatakuliah]);

      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('Error getting mahasiswa: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }
} 