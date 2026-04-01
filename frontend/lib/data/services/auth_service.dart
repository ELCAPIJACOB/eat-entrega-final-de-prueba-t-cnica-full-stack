import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'current_user';

  /// Intenta autenticar y guarda el token + datos de usuario.
  /// Retorna el Usuario si el login fue exitoso.
  Future<Usuario> login(String email, String password) async {
    final response = await ApiService.instance.post(
      '/auth/login',
      {'email': email, 'password': password},
      requireAuth: false,
    );

    final token = response['data']['token'] as String;
    final usuarioData = response['data']['usuario'] as Map<String, dynamic>;
    final usuario = Usuario.fromJson(usuarioData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(usuarioData));

    return usuario;
  }

  /// Cierra sesión limpiando datos persistidos.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Retorna el JWT almacenado o null.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Retorna el usuario de la sesión activa o null.
  Future<Usuario?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return Usuario.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  /// Retorna true si hay un token guardado.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Extrae el rol del JWT sin verificar firma (solo lectura).
  Future<String?> getRolFromToken() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['rol'] as String?;
    } catch (_) {
      return null;
    }
  }
}
