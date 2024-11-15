import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinProvider extends ChangeNotifier {
  static const String _pinKey = 'pin_code';
  static const String _pinEnabledKey = 'pin_enabled';

  bool _isPinEnabled = false;
  String? _pin;
  bool _isInitialized = false;

  bool get isPinEnabled => _isPinEnabled;
  bool get isInitialized => _isInitialized;
  
  PinProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPinEnabled = prefs.getBool(_pinEnabledKey) ?? false;
    _pin = prefs.getString(_pinKey);
    _isInitialized = true;
    print('PinProvider initialized - Enabled: $_isPinEnabled, Has PIN: ${_pin != null}');
    notifyListeners();
  }

  Future<void> setPinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, enabled);
    
    if (!enabled) {
      await prefs.remove(_pinKey);
      _pin = null;
    }
    
    _isPinEnabled = enabled;
    print('PIN Enabled set to: $enabled');
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await prefs.setBool(_pinEnabledKey, true);
    
    _pin = pin;
    _isPinEnabled = true;
    print('PIN set to: $pin');
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    return pin == _pin;
  }
} 