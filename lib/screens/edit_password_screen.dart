import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';

class EditPasswordScreen extends StatefulWidget {
  final PasswordItem item;

  EditPasswordScreen({required this.item});

  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _siteController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    _siteController = TextEditingController(text: widget.item.site);
    _usernameController = TextEditingController(text: widget.item.username);
    _passwordController = TextEditingController(text: widget.item.password);

    void checkEdited() {
      setState(() {
        _isEdited = _siteController.text != widget.item.site ||
            _usernameController.text != widget.item.username ||
            _passwordController.text != widget.item.password;
      });
    }

    _siteController.addListener(checkEdited);
    _usernameController.addListener(checkEdited);
    _passwordController.addListener(checkEdited);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: AppStyles.surface,
        elevation: 0,
        title: Text('비밀번호 수정', style: AppStyles.title),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppStyles.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEdited)
            TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: TextButton.styleFrom(
                foregroundColor: AppStyles.primary,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppStyles.primary,
                        ),
                      ),
                    )
                  : Text('저장'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppStyles.spacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppStyles.spacing),
                decoration: AppStyles.cardDecoration,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppStyles.primaryGradient,
                        borderRadius: BorderRadius.circular(AppStyles.radius),
                      ),
                      child: Center(
                        child: Text(
                          widget.item.site[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppStyles.spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('수정중', style: AppStyles.caption),
                          SizedBox(height: 4),
                          Text(widget.item.site, style: AppStyles.title),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final updatedItem = PasswordItem(
          id: widget.item.id,
          site: _siteController.text,
          username: _usernameController.text,
          password: _passwordController.text,
        );

        await context.read<PasswordProvider>().updatePassword(updatedItem);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('변경사항이 저장되었습니다'),
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