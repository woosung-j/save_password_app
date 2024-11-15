import 'package:flutter/material.dart';

class AppStateHelper {
  static final AppStateHelper _instance = AppStateHelper._internal();
  factory AppStateHelper() => _instance;
  AppStateHelper._internal();

  DateTime? _pausedTime;
  bool _needsAuth = false;

  void onPause() {
    _pausedTime = DateTime.now();
    _needsAuth = true;
  }

  bool shouldShowAuth() {
    if (_pausedTime == null || !_needsAuth) return false;
    
    final difference = DateTime.now().difference(_pausedTime!);
    // 테스트용 20초
    return difference.inSeconds >= 20;
  }

  void resetAuth() {
    _needsAuth = false;
    _pausedTime = null;
  }
} 