import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../providers/pin_provider.dart';
import '../providers/biometric_provider.dart';
import 'home_screen.dart';
import 'pin_entry_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    print('Starting initialization...');
    
    // Provider 초기화를 위한 충분한 지연
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    final biometricProvider = context.read<BiometricProvider>();
    final pinProvider = context.read<PinProvider>();

    // Provider 상태가 완전히 로드될 때까지 대기
    while (!mounted || 
           !biometricProvider.isInitialized || 
           !pinProvider.isInitialized) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    final isBiometricEnabled = biometricProvider.isBiometricEnabled;
    final isPinEnabled = pinProvider.isPinEnabled;

    print('Security settings loaded - Biometric: $isBiometricEnabled, PIN: $isPinEnabled');

    if (isBiometricEnabled) {
      print('Attempting biometric authentication');
      try {
        final authenticated = await biometricProvider.authenticate();
        if (authenticated) {
          print('Biometric authentication successful');
          _navigateToHome();
          return;
        } else {
          print('Biometric authentication failed');
        }
      } catch (e) {
        print('Biometric authentication error: $e');
      }
    }

    if (isPinEnabled) {
      print('PIN authentication required');
      _navigateToPinScreen();
    } else {
      print('No security enabled, going to home');
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    print('Navigating to home screen');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void _navigateToPinScreen() {
    if (!mounted) return;
    print('Navigating to PIN screen');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PinEntryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primary),
        ),
      ),
    );
  }
} 