import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../providers/pin_provider.dart';
import 'home_screen.dart';

class PinEntryScreen extends StatefulWidget {
  final bool isSetup;
  final bool isVerification;
  final bool isAppReentry;
  final bool isChanging;
  final VoidCallback? onVerificationSuccess;
  
  const PinEntryScreen({
    Key? key,
    this.isSetup = false,
    this.isVerification = false,
    this.isAppReentry = false,
    this.isChanging = false,
    this.onVerificationSuccess,
  }) : super(key: key);
  
  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = '';
  String? _confirmPin;
  String _message = '';
  bool _isError = false;

  void _addDigit(String digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _isError = false;
        _message = '';
      });

      if (_pin.length == 6) {
        _handlePinComplete();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
        _message = '';
      });
    }
  }

  Future<void> _handlePinComplete() async {
    if (widget.isSetup) {
      if (_confirmPin == null) {
        _confirmPin = _pin;
        setState(() {
          _message = 'PIN을 한번 더 입력해주세요';
          _pin = '';
        });
      } else {
        if (_pin == _confirmPin) {
          await context.read<PinProvider>().setPin(_pin);
          Navigator.pop(context);
        } else {
          setState(() {
            _pin = '';
            _confirmPin = null;
            _isError = true;
            _message = 'PIN이 일치하지 않습니다';
          });
        }
      }
    } else {
      final isValid = await context.read<PinProvider>().verifyPin(_pin);
      if (isValid) {
        if (widget.onVerificationSuccess != null) {
          widget.onVerificationSuccess!();
        } else if (widget.isVerification) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      } else {
        setState(() {
          _pin = '';
          _isError = true;
          _message = '잘못된 PIN입니다';
        });
      }
    }
  }

  String _getHeaderText() {
    if (widget.isSetup) {
      if (widget.isChanging) {
        return _confirmPin == null ? '새로운 PIN을 입력해주세요' : '새로운 PIN을 한번 더 입력해주세요';
      }
      return _confirmPin == null ? 'PIN을 입력해주세요' : 'PIN을 한번 더 입력해주세요';
    } else if (widget.isVerification) {
      return '현재 PIN을 입력해주세요';
    } else if (widget.isAppReentry) {
      return '잠금을 해제하려면\nPIN을 입력하세요';
    }
    return 'PIN을 입력하세요';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.isSetup || widget.isVerification,
      child: Scaffold(
        backgroundColor: AppStyles.background,
        appBar: widget.isSetup || widget.isVerification ? AppBar(
          backgroundColor: AppStyles.surface,
          elevation: 0,
          title: Text(
            widget.isChanging ? 'PIN 변경' : 'PIN 설정',
            style: AppStyles.title
          ),
          leading: IconButton(
            icon: Icon(Icons.close, color: AppStyles.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ) : null,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: _isError ? AppStyles.error : AppStyles.primary,
                    ),
                    SizedBox(height: 24),
                    Text(
                      _getHeaderText(),
                      style: AppStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    if (_message.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        _message,
                        style: AppStyles.caption.copyWith(
                          color: _isError ? AppStyles.error : AppStyles.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 16,
                          height: 16,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _pin.length
                                ? _isError ? AppStyles.error : AppStyles.primary
                                : AppStyles.divider,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Container(
                color: AppStyles.surface,
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Row(
                        children: [
                          for (var j = 1; j <= 3; j++)
                            Expanded(
                              child: _buildKeypadButton((i * 3 + j).toString()),
                            ),
                        ],
                      ),
                    Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Expanded(child: _buildKeypadButton('0')),
                        Expanded(
                          child: _buildKeypadButton(
                            '←',
                            onTap: _removeDigit,
                            icon: Icons.backspace_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    String value, {
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _addDigit(value),
        child: Container(
          height: 64,
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppStyles.textPrimary)
                : Text(
                    value,
                    style: AppStyles.heading.copyWith(
                      color: AppStyles.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
} 