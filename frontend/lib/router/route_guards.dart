import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/shared/access_denied_screen.dart';

/// Evaluación centralizada de guards de ruta.
///
/// Si ENABLE_ROUTE_GUARDS = false (modo Smoke Tests), este guard
/// siempre retorna null (sin bloqueos).
class RouteGuard {
  RouteGuard._();

  /// Evalúa si el usuario puede acceder a la ruta.
  /// Retorna el Widget de redirección si se debe bloquear,
  /// o null si puede continuar normalmente.
  static Future<Widget?> evaluate({
    required List<String> allowedRoles,
  }) async {
    // En modo Smoke Tests no se bloquea nada
    if (!ENABLE_ROUTE_GUARDS) return null;

    final isLoggedIn = await AuthService.instance.isLoggedIn();
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    if (allowedRoles.isNotEmpty) {
      final rol = await AuthService.instance.getRolFromToken();
      if (rol == null || !allowedRoles.contains(rol)) {
        return const AccessDeniedScreen();
      }
    }

    return null;
  }
}
