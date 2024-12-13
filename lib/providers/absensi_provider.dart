import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/absensi.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';

class AbsensiProvider with ChangeNotifier {
  List<Absensi> _absensiList = [];
  List<Absensi> get absensiList => _absensiList;

  Future<void> getAllAbsensi() async {
    try {
      final conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT a.*, m.nama as nama_mahasiswa, m.npm,
               mk.nama_matkul, mk.kode_matakul,
               j.ruangan, j.jam
        FROM absensi a
        JOIN mahasiswa m ON a.id_mahasiswa = m.id
        JOIN jadwal j ON a.id_jadwal = j.id
        JOIN mata_kuliah mk ON j.id_matakuliah = mk.id
      ''');
      await conn.close();

      _absensiList = results.map((row) => Absensi.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting absensi: $e');
    }
  }

  Future<void> getAbsensiByMahasiswa(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT a.*, m.nama as nama_mahasiswa, m.npm,
               mk.nama_matkul, mk.kode_matakul, mk.sks
        FROM absensi a
        JOIN mahasiswa m ON a.id_mahasiswa = m.id
        JOIN mata_kuliah mk ON a.id_matakuliah = mk.id
        WHERE m.id_user = ?
        ORDER BY mk.nama_matkul, a.pertemuan
      ''', [userId]);

      _absensiList = results.map((row) => Absensi.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting absensi: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<bool> addAbsensi(int idMahasiswa, int idJadwal, String tanggal, String status) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      await conn.query(
        'INSERT INTO absensi (id_mahasiswa, id_jadwal, tanggal, status) VALUES (?, ?, ?, ?)',
        [idMahasiswa, idJadwal, tanggal, status]
      );
      await conn.close();
      await getAllAbsensi();
      return true;
    } catch (e) {
      print('Error adding absensi: $e');
      return false;
    }
  }

  Future<bool> updateAbsensi(int id, String status) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      await conn.query(
        'UPDATE absensi SET status = ? WHERE id = ?',
        [status, id]
      );
      await conn.close();
      await getAllAbsensi();
      return true;
    } catch (e) {
      print('Error updating absensi: $e');
      return false;
    }
  }

  Future<bool> deleteAbsensi(int id) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      await conn.query('DELETE FROM absensi WHERE id = ?', [id]);
      await conn.close();
      await getAllAbsensi();
      return true;
    } catch (e) {
      print('Error deleting absensi: $e');
      return false;
    }
  }

  Future<void> getJadwalDosen(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT j.id, j.ruangan, j.hari, j.jam,
               mk.nama_matkul, mk.kode_matakul
        FROM jadwal j
        JOIN mata_kuliah mk ON j.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        WHERE d.id_user = ?
      ''', [userId]);

      _absensiList = results.map((row) => Absensi.fromMap({
        'id': row['id'],
        'id_jadwal': row['id'],
        'tanggal': DateTime.now().toString(),
        'status': 'Hadir',
        'nama_matkul': row['nama_matkul'],
        'kode_matakul': row['kode_matakul'],
        'ruangan': row['ruangan'],
        'jam': row['jam'],
      })).toList();
      
      notifyListeners();
    } catch (e) {
      print('Error getting jadwal dosen: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<bool> buatAbsensi(int idJadwal, String tanggal, int pertemuan) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      var existing = await conn.query(
        'SELECT id FROM absensi WHERE id_jadwal = ? AND pertemuan = ?',
        [idJadwal, pertemuan]
      );
      
      if (existing.isNotEmpty) {
        print('Absensi untuk pertemuan ini sudah ada');
        return false;
      }

      var mahasiswa = await conn.query('''
        SELECT m.id, m.nama, m.npm
        FROM mahasiswa m
        JOIN krs k ON k.id_mahasiswa = m.id
        JOIN mata_kuliah mk ON k.id_matakuliah = mk.id
        JOIN jadwal j ON j.id_matakuliah = mk.id
        WHERE j.id = ? AND k.status = 'approved'
      ''', [idJadwal]);

      for (var mhs in mahasiswa) {
        await conn.query('''
          INSERT INTO absensi (
            id_mahasiswa, id_jadwal, tanggal, 
            status, pertemuan
          ) VALUES (?, ?, ?, 'Alpa', ?)
        ''', [mhs['id'], idJadwal, tanggal, pertemuan]);
      }

      return true;
    } catch (e) {
      print('Error membuat absensi: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<void> getDetailAbsensi(int idJadwal, int pertemuan) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT a.*, m.nama as nama_mahasiswa, m.npm,
               mk.nama_matkul, mk.kode_matakul,
               j.ruangan, j.jam
        FROM absensi a
        JOIN mahasiswa m ON a.id_mahasiswa = m.id
        JOIN jadwal j ON a.id_jadwal = j.id
        JOIN mata_kuliah mk ON j.id_matakuliah = mk.id
        WHERE a.id_jadwal = ? AND a.pertemuan = ?
      ''', [idJadwal, pertemuan]);

      _absensiList = results.map((row) => Absensi.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting detail absensi: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<bool> updateStatusAbsensi(int id, String status) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      await conn.query(
        'UPDATE absensi SET status = ? WHERE id = ?',
        [status, id]
      );
      return true;
    } catch (e) {
      print('Error updating absensi: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<List<Map<String, dynamic>>> getMahasiswaByDosen(int userId) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT DISTINCT m.id, m.nama, m.npm, mk.nama_matkul, mk.kode_matakul
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

  Future<bool> tambahAbsensi(int idMahasiswa, int idMatakuliah, String tanggal, String status, int pertemuan) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      var existing = await conn.query('''
        SELECT id FROM absensi 
        WHERE id_mahasiswa = ? AND id_matakuliah = ? AND pertemuan = ? AND tanggal = ?
      ''', [idMahasiswa, idMatakuliah, pertemuan, tanggal]);
      
      if (existing.isNotEmpty) {
        print('Absensi untuk mahasiswa ini sudah ada');
        return false;
      }

      await conn.query('''
        INSERT INTO absensi (id_mahasiswa, id_matakuliah, tanggal, status, pertemuan)
        VALUES (?, ?, ?, ?, ?)
      ''', [idMahasiswa, idMatakuliah, tanggal, status, pertemuan]);

      return true;
    } catch (e) {
      print('Error menambah absensi: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<void> getAbsensiByDosen(int userId, {int? pertemuan, DateTime? tanggal}) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var query = '''
        SELECT a.*, m.nama as nama_mahasiswa, m.npm,
               mk.nama_matkul, mk.kode_matakul
        FROM absensi a
        JOIN mahasiswa m ON a.id_mahasiswa = m.id
        JOIN mata_kuliah mk ON a.id_matakuliah = mk.id
        JOIN dosen d ON mk.id_dosen = d.id
        WHERE d.id_user = ?
      ''';
      List<Object> params = [userId];

      if (pertemuan != null) {
        query += ' AND a.pertemuan = ?';
        params.add(pertemuan);
      }

      if (tanggal != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(tanggal);
        query += ' AND DATE(a.tanggal) = STR_TO_DATE(?, \'%Y-%m-%d\')';
        params.add(formattedDate);
      }

      query += ' ORDER BY a.tanggal DESC';

      var results = await conn.query(query, params);
      _absensiList = results.map((row) => Absensi.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting absensi by dosen: $e');
    } finally {
      await conn?.close();
    }
  }

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