import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';

class AddPasswordScreen extends StatefulWidget {
  @override
  _AddPasswordScreenState createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _siteController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: AppStyles.surface,
        elevation: 0,
        title: Text('새 비밀번호 추가', style: AppStyles.title),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppStyles.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.spacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('사이트', style: AppStyles.caption),
              SizedBox(height: 8),
              TextFormField(
                controller: _siteController,
                decoration: AppStyles.inputDecoration(
                  '사이트 주소 입력',
                  prefixIcon: Icons.language,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? '사이트를 입력해주세요' : null,
              ),
              SizedBox(height: 20),
              Text('아이디', style: AppStyles.caption),
              SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                decoration: AppStyles.inputDecoration(
                  '아이디 입력',
                  prefixIcon: Icons.person_outline,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? '아이디를 입력해주세요' : null,
              ),
              SizedBox(height: 20),
              Text('비밀번호', style: AppStyles.caption),
              SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: AppStyles.inputDecoration(
                  '비밀번호 입력',
                  prefixIcon: Icons.lock_outline,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? '비밀번호를 입력해주세요' : null,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePassword,
                  style: AppStyles.primaryButton,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('저장하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await context.read<PasswordProvider>().addPassword(
              _siteController.text,
              _usernameController.text,
              _passwordController.text,
            );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호가 저장되었습니다'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppStyles.primary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장에 실패했습니다'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppStyles.error,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
} 