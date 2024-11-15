import 'package:flutter/foundation.dart';
import '../models/password_item.dart';
import '../services/db_helper.dart';
import '../helpers/hangul_helper.dart';

class PasswordProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<PasswordItem> _passwords = [];
  List<PasswordItem> _filteredPasswords = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<PasswordItem> get passwords => _passwords;
  List<PasswordItem> get filteredPasswords => 
    _searchQuery.isEmpty ? _passwords : _filteredPasswords;

  PasswordProvider() {
    loadPasswords(); // 생성자에서 바로 데이터 로드
  }

  // 초기 데이터 로드
  Future<void> loadPasswords() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Loading passwords...'); // 디버깅용
      _passwords = await _dbHelper.getAllPasswords();
      print('Loaded ${_passwords.length} passwords'); // 디버깅용
      
      if (_searchQuery.isNotEmpty) {
        search(_searchQuery);
      } else {
        _filteredPasswords = _passwords;
      }
    } catch (e) {
      print('Error in loadPasswords: $e');
      _passwords = [];
      _filteredPasswords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 비밀번호 추가
  Future<void> addPassword(String site, String username, String password) async {
    try {
      final newItem = PasswordItem(
        site: site,
        username: username,
        password: password,
      );

      final id = await _dbHelper.insertPassword(newItem);
      if (id != -1) {
        await loadPasswords(); // 성공적으로 추가된 후 전체 데이터 다시 로드
      }
    } catch (e) {
      print('Error in addPassword: $e');
      rethrow;
    }
  }

  // 검색 기능
  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredPasswords = _passwords;
    } else {
      _filteredPasswords = _passwords.where((item) {
        return HangulHelper.matchesSearch(item.site, query) || 
               HangulHelper.matchesSearch(item.username, query);
      }).toList();
    }
    notifyListeners();
  }

  // 비밀번호 삭제
  Future<void> deletePassword(int id) async {
    try {
      await _dbHelper.deletePassword(id);
      _passwords.removeWhere((item) => item.id == id);
      
      if (_searchQuery.isNotEmpty) {
        search(_searchQuery);
      }
      notifyListeners();
    } catch (e) {
      print('Error deleting password: $e');
      rethrow;
    }
  }

  // 비밀번호 수정
  Future<void> updatePassword(PasswordItem item) async {
    try {
      await _dbHelper.updatePassword(item);
      
      final index = _passwords.indexWhere((p) => p.id == item.id);
      if (index != -1) {
        _passwords[index] = item;
        
        if (_searchQuery.isNotEmpty) {
          search(_searchQuery);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }
} 