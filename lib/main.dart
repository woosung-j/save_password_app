import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:save_password/screens/home_screen.dart';
import 'providers/password_provider.dart';
import 'providers/pin_provider.dart';
import 'providers/biometric_provider.dart';
import 'screens/pin_entry_screen.dart';
import 'screens/splash_screen.dart';
import 'constants/styles.dart';
import 'helpers/app_state_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
        ChangeNotifierProvider(create: (_) => PinProvider()),
        ChangeNotifierProvider(create: (_) => BiometricProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '비밀번호 관리',
      theme: ThemeData(
        primaryColor: AppStyles.primary,
        scaffoldBackgroundColor: AppStyles.background,
      ),
      home: SplashScreen(),
    );
  }
}
