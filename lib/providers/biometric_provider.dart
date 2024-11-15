import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_service.dart';

class BiometricProvider extends ChangeNotifier {
  final BiometricService _biometricService = BiometricService();
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isInitialized = false;

  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isInitialized => _isInitialized;

  BiometricProvider() {
    _init();
  }

  Future<void> _init() async {
    _isBiometricAvailable = await _biometricService.isBiometricAvailable();
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    _isInitialized = true;
    print('BiometricProvider initialized - Available: $_isBiometricAvailable, Enabled: $_isBiometricEnabled');
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    print('Setting biometric enabled: $enabled');
    if (!_isBiometricAvailable) {
      print('Biometric not available, cannot enable');
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    _isBiometricEnabled = enabled;
    print('Biometric enabled set to: $_isBiometricEnabled');
    notifyListeners();
  }

  Future<bool> authenticateSetup() async {
    print('Attempting to authenticate for setup');
    if (!_isBiometricAvailable) {
      print('Biometric not available for setup');
      return false;
    }

    return await _biometricService.authenticate();
  }

  Future<bool> authenticate() async {
    print('Attempting to authenticate with biometrics');
    if (!_isBiometricAvailable) {
      print('Biometric not available');
      return false;
    }
    
    if (!_isBiometricEnabled) {
      print('Biometric not enabled');
      return false;
    }

    return await _biometricService.authenticate();
  }
} 