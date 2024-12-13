import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../database/database_helper.dart';
import '../models/jadwal.dart';

class JadwalProvider with ChangeNotifier {
  List<Jadwal> _jadwalList = [];
  List<Jadwal> get jadwalList => _jadwalList;

  Future<void> getAllJadwal() async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT j.*, mk.nama_matkul, mk.kode_matakul,
               d.nama as nama_dosen
        FROM jadwal j
        JOIN mata_kuliah mk ON j.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        ORDER BY FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.jam
      ''');

      _jadwalList = results.map((row) => Jadwal.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting jadwal: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<bool> addJadwal(int idMatakuliah, String hari, String jam, String ruangan) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      // Cek jadwal bentrok
      var existing = await conn.query('''
        SELECT id FROM jadwal 
        WHERE hari = ? AND ruangan = ? AND 
        ((TIME(?) BETWEEN jam AND ADDTIME(jam, '01:40:00')) OR
         (ADDTIME(TIME(?), '01:40:00') BETWEEN jam AND ADDTIME(jam, '01:40:00')))
      ''', [hari, ruangan, jam, jam]);

      if (existing.isNotEmpty) {
        print('Jadwal bentrok di ruangan dan waktu yang sama');
        return false;
      }

      await conn.query(
        'INSERT INTO jadwal (id_matakuliah, hari, jam, ruangan) VALUES (?, ?, ?, ?)',
        [idMatakuliah, hari, jam, ruangan]
      );
      
      await getAllJadwal();
      return true;
    } catch (e) {
      print('Error adding jadwal: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> updateJadwal(int id, int idMatakuliah, String hari, String jam, String ruangan) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      // Cek jadwal bentrok kecuali dengan jadwal yang sedang diupdate
      var existing = await conn.query('''
        SELECT id FROM jadwal 
        WHERE id != ? AND hari = ? AND ruangan = ? AND 
        ((TIME(?) BETWEEN jam AND ADDTIME(jam, '01:40:00')) OR
         (ADDTIME(TIME(?), '01:40:00') BETWEEN jam AND ADDTIME(jam, '01:40:00')))
      ''', [id, hari, ruangan, jam, jam]);

      if (existing.isNotEmpty) {
        print('Jadwal bentrok di ruangan dan waktu yang sama');
        return false;
      }

      await conn.query(
        'UPDATE jadwal SET id_matakuliah = ?, hari = ?, jam = ?, ruangan = ? WHERE id = ?',
        [idMatakuliah, hari, jam, ruangan, id]
      );
      
      await getAllJadwal();
      return true;
    } catch (e) {
      print('Error updating jadwal: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> deleteJadwal(int id) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query('DELETE FROM jadwal WHERE id = ?', [id]);
      await getAllJadwal();
      return true;
    } catch (e) {
      print('Error deleting jadwal: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<void> getJadwalMahasiswa(int userId) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT j.*, mk.nama_matkul, mk.kode_matakul, d.nama as nama_dosen
        FROM jadwal j
        JOIN mata_kuliah mk ON j.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        JOIN krs k ON k.id_matakuliah = mk.id
        JOIN mahasiswa m ON k.id_mahasiswa = m.id
        WHERE m.id_user = ? AND k.status = 'approved'
      ''', [userId]);
      await conn.close();

      _jadwalList = results.map((row) => Jadwal.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting jadwal mahasiswa: $e');
    }
  }

  Future<void> getJadwalDosen(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT j.*, mk.nama_matkul, mk.kode_matakul, mk.sks
        FROM jadwal j
        JOIN mata_kuliah mk ON j.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        WHERE d.id_user = ?
        ORDER BY j.hari, j.jam
      ''', [userId]);

      _jadwalList = results.map((row) => Jadwal.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting jadwal dosen: $e');
    } finally {
      await conn?.close();
    }
  }
} 