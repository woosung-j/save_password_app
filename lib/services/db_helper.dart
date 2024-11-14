import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/password_item.dart';
import '../services/encryption_service.dart';

class DBHelper {
  static Database? _db;
  static const String _dbName = 'passwords.db';
  
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    
    print('DB Path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('Creating new database tables');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS passwords(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            site TEXT NOT NULL,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
      },
      onOpen: (db) async {
        print('Database opened');
        var tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='passwords'"
        );
        print('Existing tables: $tables');

        var result = await db.rawQuery('SELECT COUNT(*) as count FROM passwords');
        print('Current number of stored passwords: ${result.first['count']}');
      },
    );
  }

  Future<int> insertPassword(PasswordItem item) async {
    try {
      final db = await database;
      final encryptedPassword = await EncryptionService.encrypt(item.password);
      
      final data = {
        'site': item.site,
        'username': item.username,
        'password': encryptedPassword,
      };
      
      print('Inserting data: $data');
      final id = await db.insert('passwords', data);
      print('Inserted with ID: $id');
      return id;
    } catch (e) {
      print('Error in insertPassword: $e');
      throw Exception('Failed to insert password: $e');
    }
  }

  Future<List<PasswordItem>> getAllPasswords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('passwords');
      print('Found ${maps.length} passwords');

      List<PasswordItem> items = [];
      for (var map in maps) {
        try {
          final decryptedPassword = await EncryptionService.decrypt(map['password'] as String);
          items.add(PasswordItem(
            id: map['id'] as int,
            site: map['site'] as String,
            username: map['username'] as String,
            password: decryptedPassword,
          ));
        } catch (e) {
          print('Error processing password: $e');
        }
      }
      return items;
    } catch (e) {
      print('Error in getAllPasswords: $e');
      throw Exception('Failed to load passwords: $e');
    }
  }

  Future<void> updatePassword(PasswordItem item) async {
    try {
      final db = await database;
      final encryptedPassword = await EncryptionService.encrypt(item.password);
      
      await db.update(
        'passwords',
        {
          'site': item.site,
          'username': item.username,
          'password': encryptedPassword,
        },
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      print('Error in updatePassword: $e');
      throw Exception('Failed to update password: $e');
    }
  }

  Future<void> deletePassword(int id) async {
    try {
      final db = await database;
      await db.delete(
        'passwords',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error in deletePassword: $e');
      throw Exception('Failed to delete password: $e');
    }
  }
} 