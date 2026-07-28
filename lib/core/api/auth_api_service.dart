import 'package:dio/dio.dart';

class AuthSession {
  AuthSession({required this.access, this.refresh, this.user});

  final String access;
  final String? refresh;
  final Map<String, dynamic>? user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final u = json['user'];
    return AuthSession(
      access: json['access'] as String,
      refresh: json['refresh'] as String?,
      user: u is Map ? Map<String, dynamic>.from(u) : null,
    );
  }

  List<String> get groups {
    final g = user?['groups'];
    if (g is! List) return const [];
    return g.map((e) => e.toString()).toList();
  }

  bool hasGroup(String name) {
    final n = name.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    return groups.any(
      (g) => g.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '') == n,
    );
  }
}

class AuthApiService {
  AuthApiService(this._dio);
  final Dio _dio;

  Future<AuthSession> staffLogin({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/admin-login/',
      data: {'phone': phone, 'password': password},
    );
    return AuthSession.fromJson(
      Map<String, dynamic>.from(res.data ?? const {}),
    );
  }

  Future<Map<String, dynamic>> fetchMe() async {
    final res = await _dio.get<Map<String, dynamic>>('users/me/');
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    await _dio.put<dynamic>(
      'users/me/update/',
      data: {'first_name': firstName, 'last_name': lastName},
    );
  }
}
