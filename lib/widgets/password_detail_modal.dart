import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';
import '../screens/edit_password_screen.dart';

class PasswordDetailModal extends StatelessWidget {
  final PasswordItem item;

  PasswordDetailModal({required this.item});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 복사되었습니다'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppStyles.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppStyles.surface,
        borderRadius: BorderRadius.circular(AppStyles.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppStyles.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppStyles.spacing),
            child: Column(
              children: [
                Row(
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
                          item.site[0].toUpperCase(),
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
                          Text(item.site, style: AppStyles.title),
                          SizedBox(height: 4),
                          Text('비밀번호 정보', style: AppStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildDetailItem(
                  context,
                  label: '사이트',
                  value: item.site,
                  icon: Icons.language,
                  onCopy: () => _copyToClipboard(context, item.site, '사이트 주소'),
                ),
                _buildDetailItem(
                  context,
                  label: '아이디',
                  value: item.username,
                  icon: Icons.person_outline,
                  onCopy: () => _copyToClipboard(context, item.username, '아이디'),
                ),
                _buildDetailItem(
                  context,
                  label: '비밀번호',
                  value: item.password,
                  icon: Icons.lock_outline,
                  onCopy: () => _copyToClipboard(context, item.password, '비밀번호'),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPasswordScreen(item: item),
                            ),
                          );
                        },
                        style: AppStyles.primaryButton,
                        child: Text('수정하기'),
                      ),
                    ),
                    SizedBox(width: AppStyles.spacing),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        style: AppStyles.secondaryButton.copyWith(
                          foregroundColor:
                              MaterialStateProperty.all(AppStyles.error),
                          side: MaterialStateProperty.all(
                            BorderSide(color: AppStyles.error),
                          ),
                        ),
                        child: Text('삭제하기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(AppStyles.spacing),
      decoration: BoxDecoration(
        color: AppStyles.background,
        borderRadius: BorderRadius.circular(AppStyles.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppStyles.textSecondary),
              SizedBox(width: 8),
              Text(label, style: AppStyles.caption),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(value, style: AppStyles.body),
              ),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: AppStyles.primary),
                onPressed: onCopy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('비밀번호 삭제', style: AppStyles.title),
        content: Text(
          '정말 삭제하시겠습니까?',
          style: AppStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);
              try {
                await context.read<PasswordProvider>().deletePassword(item.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('비밀번호가 삭제되었습니다'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppStyles.primary,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('삭제에 실패했습니다'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppStyles.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppStyles.error,
            ),
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }
} 