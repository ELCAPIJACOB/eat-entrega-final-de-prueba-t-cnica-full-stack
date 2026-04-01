/// Configuración global de la aplicación NexGen.
///
/// Para activar el modo Smoke Tests (navegar sin autenticación),
/// cambia ENABLE_ROUTE_GUARDS a false:
///
///   flutter run --dart-define=ENABLE_ROUTE_GUARDS=false
///
/// O simplemente cambia la constante directamente para desarrollo.
library;

import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

// ignore_for_file: constant_identifier_names

/// Controla si los guards de rutas están activos.
/// true  = modo PRODUCCIÓN (JWT + roles verificados)
/// false = modo SMOKE TESTS (navegación libre, sin autenticación)
const bool ENABLE_ROUTE_GUARDS =
    bool.fromEnvironment('ENABLE_ROUTE_GUARDS', defaultValue: true);

String _getApiUrl() {
  if (kIsWeb) return 'http://localhost:3000/api';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
  } catch (_) {}
  return 'http://localhost:3000/api';
}

/// URL base de la API REST.
final String API_BASE_URL =
    String.fromEnvironment('API_BASE_URL', defaultValue: _getApiUrl());
