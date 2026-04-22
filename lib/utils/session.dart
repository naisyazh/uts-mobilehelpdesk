class Session {
  static Map<String, dynamic>? _user;

  static void setUser(Map<String, dynamic> user) => _user = user;
  static Map<String, dynamic>? getUser() => _user;
  static String getRole() => _user?['role'] ?? 'user';
  static String getName() => _user?['name'] ?? '';
  static String getEmail() => _user?['email'] ?? '';
  static void clear() => _user = null;
}