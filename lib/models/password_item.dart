class PasswordItem {
  final int? id;
  final String site;
  final String username;
  final String password;

  PasswordItem({
    this.id,
    required this.site,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'site': site,
      'username': username,
      'password': password,
    };
  }

  factory PasswordItem.fromMap(Map<String, dynamic> map) {
    return PasswordItem(
      id: map['id'],
      site: map['site'],
      username: map['username'],
      password: map['password'],
    );
  }

  @override
  String toString() {
    return 'PasswordItem(id: $id, site: $site, username: $username)';
  }
} 