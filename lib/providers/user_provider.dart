import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  List<User> _userList = [];
  List<User> get userList => _userList;

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  Future<void> getAllUsers() async {
    try {
      final conn = await DatabaseHelper.getConnection();
      var results = await conn.query('SELECT * FROM user');
      await conn.close();

      _userList = results.map((row) => User.fromMap(row.fields)).toList();
      notifyListeners();
    } catch (e) {
      print('Error getting users: $e');
    }
  }

  Future<int?> addUser(String username, String password, String role) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      var result = await conn.query(
        'INSERT INTO user (username, password, role) VALUES (?, ?, ?)',
        [username, _hashPassword(password), role]
      );
      await conn.close();
      await getAllUsers();
      return result.insertId; // Return ID dari user yang baru dibuat
    } catch (e) {
      print('Error adding user: $e');
      return null;
    }
  }

  Future<bool> updateUser(int id, String username, String? password, String role) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      if (password != null) {
        // Update dengan password baru
        await conn.query(
          'UPDATE user SET username = ?, password = MD5(?), role = ? WHERE id = ?',
          [username, password, role, id]
        );
      } else {
        // Update tanpa mengubah password
        await conn.query(
          'UPDATE user SET username = ?, role = ? WHERE id = ?',
          [username, role, id]
        );
      }
      
      await getAllUsers();
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> deleteUser(int id) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      
      // Get user role first
      var userResult = await conn.query(
        'SELECT role FROM user WHERE id = ?',
        [id]
      );
      
      if (userResult.isNotEmpty) {
        String role = userResult.first['role'];
        
        // Delete related data based on role
        if (role == 'mahasiswa') {
          await conn.query('DELETE FROM mahasiswa WHERE id_user = ?', [id]);
        } else if (role == 'dosen') {
          await conn.query('DELETE FROM dosen WHERE id_user = ?', [id]);
        }
        
        // Delete user
        await conn.query('DELETE FROM user WHERE id = ?', [id]);
      }
      
      await getAllUsers();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<List<User>> getUnassignedUsers() async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT u.* FROM user u
        LEFT JOIN mahasiswa m ON u.id = m.id_user
        WHERE u.role = 'mahasiswa' AND m.id IS NULL
      ''');

      print('Unassigned mahasiswa users found: ${results.length}'); // Debug print
      for (var row in results) {
        print('User mahasiswa: ${row.fields}'); // Debug print
      }

      return results.map((row) => User.fromMap(row.fields)).toList();
    } catch (e) {
      print('Error getting unassigned users: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  Future<List<User>> getUnassignedDosenUsers() async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.getConnection();
      var results = await conn.query('''
        SELECT u.* FROM user u
        LEFT JOIN dosen d ON u.id = d.id_user
        WHERE u.role = 'dosen' AND d.id IS NULL
      ''');

      print('Unassigned dosen users found: ${results.length}'); // Debug print
      for (var row in results) {
        print('User dosen: ${row.fields}'); // Debug print
      }

      return results.map((row) => User.fromMap(row.fields)).toList();
    } catch (e) {
      print('Error getting unassigned dosen users: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }
} 