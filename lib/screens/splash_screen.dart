import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../providers/pin_provider.dart';
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 최소 스플래시 표시 시간 설정
    await Future.delayed(Duration(seconds: 1));
    
    if (!mounted) return;

    // PinProvider가 초기화될 때까지 대기
    final pinProvider = context.read<PinProvider>();
    while (!pinProvider.isInitialized) {
      await Future.delayed(Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // PIN 상태에 따라 화면 전환
    if (pinProvider.isPinEnabled) {
      print('PIN is enabled, navigating to PIN entry screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PinEntryScreen()),
      );
    } else {
      print('PIN is disabled, navigating to home screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: AppStyles.primary,
            ),
            SizedBox(height: 16),
            Text(
              '비밀번호 관리',
              style: AppStyles.heading,
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primary),
            ),
          ],
        ),
      ),
    );
  }
} 