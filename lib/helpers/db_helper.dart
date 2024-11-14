import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/password_item.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final pathToDb = path.join(dbPath, 'passwords.db');
    
    print('Database path: $pathToDb'); // 디버깅용

    return await openDatabase(
      pathToDb,
      version: 1,
      onCreate: (db, version) async {
        print('Creating new database'); // 디버깅용
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
        print('Database opened'); // 디버깅용
        // 테이블이 존재하는지 확인
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='passwords'"
        );
        print('Existing tables: $tables'); // 디버깅용
      },
    );
  }

  Future<List<PasswordItem>> getAllPasswords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('passwords');
      print('Fetched ${maps.length} passwords'); // 디버깅용
      
      return List.generate(maps.length, (i) {
        return PasswordItem(
          id: maps[i]['id'],
          site: maps[i]['site'],
          username: maps[i]['username'],
          password: maps[i]['password'],
        );
      });
    } catch (e) {
      print('Error getting passwords: $e');
      return [];
    }
  }

  Future<int> insertPassword(PasswordItem item) async {
    try {
      final db = await database;
      final result = await db.insert(
        'passwords',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted password with id: $result'); // 디버깅용
      return result;
    } catch (e) {
      print('Error inserting password: $e');
      return -1;
    }
  }

  Future<int> updatePassword(PasswordItem item) async {
    try {
      final db = await database;
      final result = await db.update(
        'passwords',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      print('Updated password with id: ${item.id}'); // 디버깅용
      return result;
    } catch (e) {
      print('Error updating password: $e');
      return -1;
    }
  }

  Future<int> deletePassword(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'passwords',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Deleted password with id: $id'); // 디버깅용
      return result;
    } catch (e) {
      print('Error deleting password: $e');
      return -1;
    }
  }
} 