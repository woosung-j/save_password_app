import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/styles.dart';
import '../models/password_item.dart';
import '../providers/password_provider.dart';
import 'password_detail_modal.dart';

class PasswordSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => '검색';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: AppStyles.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppStyles.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: AppStyles.caption,
      ),
      scaffoldBackgroundColor: AppStyles.background,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<PasswordProvider>(
      builder: (context, provider, _) {
        final items = provider.passwords.where((item) {
          final searchLower = query.toLowerCase();
          return item.site.toLowerCase().contains(searchLower) ||
              item.username.toLowerCase().contains(searchLower);
        }).toList();

        if (query.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 64,
                  color: AppStyles.textSecondary.withOpacity(0.5),
                ),
                SizedBox(height: AppStyles.spacing),
                Text(
                  '검색어를 입력하세요',
                  style: AppStyles.caption,
                ),
              ],
            ),
          );
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppStyles.textSecondary.withOpacity(0.5),
                ),
                SizedBox(height: AppStyles.spacing),
                Text('검색 결과가 없습니다', style: AppStyles.title),
                SizedBox(height: 8),
                Text(
                  '다른 검색어를 입력해보세요',
                  style: AppStyles.caption,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppStyles.spacing),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: AppStyles.cardDecoration,
                child: ListTile(
                  contentPadding: EdgeInsets.all(AppStyles.spacing),
                  leading: Container(
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
                  title: Text(item.site, style: AppStyles.title),
                  subtitle: Text(item.username, style: AppStyles.caption),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: AppStyles.textSecondary,
                  ),
                  onTap: () {
                    close(context, '');
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => PasswordDetailModal(item: item),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
} 