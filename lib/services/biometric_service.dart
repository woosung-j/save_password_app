import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      print('Biometric available: canCheck=$canCheck, isSupported=$isSupported');
      return canCheck && isSupported;
    } on PlatformException catch (e) {
      print('Error checking biometric availability: ${e.message}');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      print('Available biometrics: $availableBiometrics');
      
      return await _localAuth.authenticate(
        localizedReason: '지문을 인식해주세요',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          sensitiveTransaction: true,
        ),
        authMessages: [
          AndroidAuthMessages(
            signInTitle: '생체 인증',
            cancelButton: '취소',
            biometricHint: '지문을 인식해주세요',
            biometricNotRecognized: '지문을 인식할 수 없습니다',
            biometricSuccess: '인증되었습니다',
          ),
          IOSAuthMessages(
            cancelButton: '취소',
            goToSettingsButton: '설정',
            goToSettingsDescription: '생체 인증을 설정해주세요',
            lockOut: '생체 인증이 비활성화되었습니다',
          ),
        ],
      );
    } on PlatformException catch (e) {
      print('Authentication error: ${e.code} - ${e.message}');
      return false;
    }
  }
} 