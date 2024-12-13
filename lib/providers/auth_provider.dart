import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  Future<bool> login(String username, String password) async {
    try {
      final conn = await DatabaseHelper.getConnection();
      var results = await conn.query(
        'SELECT * FROM user WHERE username = ? AND password = ?',
        [username, _hashPassword(password)]
      );

      await conn.close();

      if (results.isNotEmpty) {
        final row = results.first;
        _user = User.fromMap(row.fields);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
} 