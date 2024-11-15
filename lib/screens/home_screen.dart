import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:save_password/screens/pin_entry_screen.dart';
import '../constants/styles.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';
import '../providers/pin_provider.dart';
import '../widgets/password_detail_modal.dart';
import '../widgets/password_search_delegate.dart';
import 'add_password_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } 
    else if (state == AppLifecycleState.resumed && _pausedTime != null) {
      final difference = DateTime.now().difference(_pausedTime!);
      final pinProvider = context.read<PinProvider>();
      
      // 테스트를 위해 20초로 설정
      if (difference.inSeconds >= 20 && pinProvider.isPinEnabled) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PinEntryScreen(isAppReentry: true),
          ),
        );
      }
      _pausedTime = null;
    }
  }

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _resetSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    context.read<PasswordProvider>().search('');
  }

  void _showPasswordDetail(PasswordItem item) {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PasswordDetailModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppStyles.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppStyles.surface,
              elevation: 0,
              title: Text('비밀번호 관리', style: AppStyles.heading),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppStyles.textPrimary,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsScreen()),
                    );
                  },
                ),
                SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppStyles.spacing),
                child: Container(
                  decoration: AppStyles.searchDecoration,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: '사이트 검색',
                      hintStyle: AppStyles.caption,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, 
                                color: AppStyles.textSecondary,
                                size: 20,
                              ),
                              onPressed: _resetSearch,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            )
                          : null,
                    ),
                    style: AppStyles.body,
                    onChanged: (value) {
                      setState(() {});
                      context.read<PasswordProvider>().search(value);
                    },
                  ),
                ),
              ),
            ),
            Consumer<PasswordProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(
                      color: AppStyles.primary,
                    )),
                  );
                }

                final items = provider.filteredPasswords;
                
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchController.text.isEmpty 
                                ? Icons.lock_outline_rounded
                                : Icons.search_off_rounded,
                            size: 64,
                            color: AppStyles.textSecondary.withOpacity(0.5),
                          ),
                          SizedBox(height: AppStyles.spacing),
                          Text(
                            _searchController.text.isEmpty 
                                ? '저장된 비밀번호가 없습니다'
                                : '검색 결과가 없습니다',
                            style: AppStyles.title
                          ),
                          SizedBox(height: 8),
                          Text(
                            _searchController.text.isEmpty 
                                ? '새로운 비밀번호를 추가해보세요'
                                : '다른 검색어를 입력해보세요',
                            style: AppStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.all(AppStyles.spacing),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _PasswordCard(
                            item: item,
                            onTap: () => _showPasswordDetail(item),
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddPasswordScreen()),
            );
          },
          backgroundColor: AppStyles.primary,
          child: Icon(Icons.add, color: Colors.white),
          elevation: AppStyles.elevation,
        ),
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  final PasswordItem item;
  final VoidCallback onTap;

  const _PasswordCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppStyles.radius),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(AppStyles.spacing),
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
                      Text(item.username, style: AppStyles.caption),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppStyles.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 