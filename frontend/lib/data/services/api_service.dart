import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../services/auth_service.dart';
import '../../main.dart';
import '../../core/constants/route_names.dart';

/// Excepción tipada para errores de API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException(${statusCode ?? 0}): $message';
}

/// Cliente HTTP base que agrega el Bearer token automáticamente
/// y maneja errores de respuesta de forma centralizada.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Future<Map<String, String>> _headers({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await AuthService.instance.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      // Ojo: Si el token muere o es inválido, pateamos al usuario al Login
      // TODO: Evaluar si a futuro metemos lógica de refresh token transparente aquí
      AuthService.instance.logout();
      import_router_and_navigate();
    }

    final message = body['message'] as String? ?? 'Error desconocido';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<dynamic> get(String path, {bool requireAuth = true}) async {
    final uri = Uri.parse('$API_BASE_URL$path');
    final headers = await _headers(requireAuth: requireAuth);
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool requireAuth = true}) async {
    final uri = Uri.parse('$API_BASE_URL$path');
    final headers = await _headers(requireAuth: requireAuth);
    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body,
      {bool requireAuth = true}) async {
    final uri = Uri.parse('$API_BASE_URL$path');
    final headers = await _headers(requireAuth: requireAuth);
    final response =
        await http.patch(uri, headers: headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {bool requireAuth = true}) async {
    final uri = Uri.parse('$API_BASE_URL$path');
    final headers = await _headers(requireAuth: requireAuth);
    final response = await http.delete(uri, headers: headers);
    return _handleResponse(response);
  }
}

void import_router_and_navigate() {
  NexGenApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
    RouteNames.login,
    (route) => false,
  );
}

