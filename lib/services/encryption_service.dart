import 'dart:math';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'encryption_key';
  
  static Future<Key> _getOrCreateKey() async {
    String? savedKey = await _storage.read(key: _keyName);
    
    if (savedKey == null) {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
      final key = base64Encode(keyBytes);
      
      await _storage.write(key: _keyName, value: key);
      return Key.fromBase64(key);
    }
    
    return Key.fromBase64(savedKey);
  }

  static Future<String> encrypt(String text) async {
    try {
      final key = await _getOrCreateKey();
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key));

      print('Encrypting text...'); // 디버깅
      final encrypted = encrypter.encrypt(text, iv: iv);
      final result = '${encrypted.base64}:${iv.base64}';
      print('Encryption successful'); // 디버깅
      return result;
    } catch (e) {
      print('Encryption error: $e'); // 디버깅
      rethrow;
    }
  }

  static Future<String> decrypt(String encryptedText) async {
    try {
      final key = await _getOrCreateKey();
      final parts = encryptedText.split(':');
      if (parts.length != 2) throw FormatException('Invalid encrypted text format');

      final encrypted = Encrypted.fromBase64(parts[0]);
      final iv = IV.fromBase64(parts[1]);
      
      final encrypter = Encrypter(AES(key));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
} 