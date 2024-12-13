import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../database/database_helper.dart';
import '../models/krs.dart';

class KRSProvider with ChangeNotifier {
  List<KRS> _krsList = [];
  List<KRS> get krsList => _krsList;

  int get totalSKS {
    int total = 0;
    for (var krs in _krsList) {
      if (krs.status == 'approved') {
        total += krs.sks ?? 0;
      }
    }
    return total;
  }

  Future<void> getKRSByMahasiswa(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT k.*, mk.nama_matkul, mk.kode_matakul, mk.sks, d.nama as nama_dosen
        FROM krs k
        JOIN mata_kuliah mk ON k.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        JOIN mahasiswa m ON k.id_mahasiswa = m.id
        WHERE m.id_user = ?
      ''', [userId]);

      _krsList = results.map((row) => KRS.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting KRS: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<bool> ajukanKRS(int userId, int idMatakuliah, String semester, String tahunAjaran) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      // Dapatkan id mahasiswa dari user_id terlebih dahulu
      var mahasiswaResult = await conn.query(
        'SELECT id FROM mahasiswa WHERE id_user = ?',
        [userId]
      );
      
      if (mahasiswaResult.isEmpty) {
        print('Mahasiswa tidak ditemukan');
        return false;
      }

      final idMahasiswa = mahasiswaResult.first['id'];

      // Cek apakah KRS untuk mata kuliah ini sudah ada
      var existingKRS = await conn.query(
        'SELECT id FROM krs WHERE id_mahasiswa = ? AND id_matakuliah = ? AND tahun_ajaran = ?',
        [idMahasiswa, idMatakuliah, tahunAjaran]
      );

      if (existingKRS.isNotEmpty) {
        print('KRS untuk mata kuliah ini sudah diajukan');
        return false;
      }

      // Insert KRS baru
      await conn.query(
        'INSERT INTO krs (id_mahasiswa, id_matakuliah, semester, tahun_ajaran) VALUES (?, ?, ?, ?)',
        [idMahasiswa, idMatakuliah, semester, tahunAjaran]
      );

      await getKRSByMahasiswa(userId);
      return true;
    } catch (e) {
      print('Error adding KRS: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> batalkanKRS(int id) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query('DELETE FROM krs WHERE id = ?', [id]);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error canceling KRS: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<void> getAllKRS() async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT k.*, m.nama as nama_mahasiswa, m.npm,
               mk.nama_matkul, mk.kode_matakul, mk.sks,
               d.nama as nama_dosen
        FROM krs k
        JOIN mahasiswa m ON k.id_mahasiswa = m.id
        JOIN mata_kuliah mk ON k.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        ORDER BY k.status ASC, m.nama ASC
      ''');

      _krsList = results.map((row) => KRS.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting all KRS: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<bool> updateStatusKRS(int id, String status) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query(
        'UPDATE krs SET status = ? WHERE id = ?',
        [status, id]
      );
      await getAllKRS();
      return true;
    } catch (e) {
      print('Error updating KRS status: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }
} 