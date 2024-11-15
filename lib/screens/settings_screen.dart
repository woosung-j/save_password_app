import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../providers/pin_provider.dart';
import 'pin_entry_screen.dart';
import '../providers/biometric_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: AppStyles.surface,
        elevation: 0,
        title: Text('환경설정', style: AppStyles.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppStyles.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSettingSection(
            title: '보안',
            items: _buildSecurityItems(context),
          ),
          _buildSettingSection(
            title: '데이터',
            items: [
              SettingItem(
                title: '백업',
                icon: Icons.backup_outlined,
                onTap: () {
                  // TODO: 백업 기능
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<SettingItem> _buildSecurityItems(BuildContext context) {
    final pinProvider = context.watch<PinProvider>();
    final biometricProvider = context.watch<BiometricProvider>();
    
    List<SettingItem> items = [
      SettingItem(
        title: 'PIN 비밀번호 사용',
        icon: Icons.lock_outline,
        trailing: Switch(
          value: pinProvider.isPinEnabled,
          onChanged: (value) async {
            if (value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PinEntryScreen(isSetup: true),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PinEntryScreen(
                    isVerification: true,
                    onVerificationSuccess: () async {
                      await pinProvider.setPinEnabled(false);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            }
          },
          activeColor: AppStyles.primary,
        ),
      ),
    ];

    if (pinProvider.isPinEnabled) {
      items.add(
        SettingItem(
          title: 'PIN 변경',
          icon: Icons.pin_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PinEntryScreen(
                  isVerification: true,
                  onVerificationSuccess: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PinEntryScreen(
                          isSetup: true,
                          isChanging: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }

    if (biometricProvider.isBiometricAvailable) {
      items.add(
        SettingItem(
          title: '지문 인식 사용',
          icon: Icons.fingerprint,
          trailing: Switch(
            value: biometricProvider.isBiometricEnabled,
            onChanged: (value) async {
              print('Biometric switch tapped: $value');
              if (value) {
                if (!pinProvider.isPinEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('먼저 PIN을 설정해주세요')),
                  );
                  return;
                }
                print('Attempting to authenticate...');
                final authenticated = await biometricProvider.authenticateSetup();
                print('Authentication result: $authenticated');
                if (authenticated) {
                  await biometricProvider.setBiometricEnabled(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('지문 인식이 활성화되었습니다')),
                  );
                }
              } else {
                await biometricProvider.setBiometricEnabled(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('지문 인식이 비활성화되었습니다')),
                );
              }
            },
            activeColor: AppStyles.primary,
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildSettingSection({
    required String title,
    required List<SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(title, style: AppStyles.caption),
        ),
        Container(
          decoration: AppStyles.cardDecoration,
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: items.map((item) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppStyles.textPrimary),
                    title: Text(item.title, style: AppStyles.body),
                    trailing: item.trailing ?? (item.onTap != null
                      ? Icon(
                          Icons.chevron_right_rounded,
                          color: AppStyles.textSecondary,
                        )
                      : null),
                    onTap: item.onTap,
                  ),
                  if (items.last != item)
                    Divider(height: 1, color: AppStyles.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SettingItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  SettingItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.trailing,
  });
} 