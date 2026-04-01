// ignore_for_file: constant_identifier_names

/// Nombres de rutas nombradas para Navigator.pushNamed
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String accessDenied = '/access-denied';

  // USUARIO
  static const String usuarioHome = '/usuario/home';
  static const String usuarioCrearIncidencia = '/usuario/crear-incidencia';
  static const String usuarioDetalleIncidencia = '/usuario/incidencia-detalle';

  // TECNICO
  static const String tecnicoHome = '/tecnico/home';
  static const String tecnicoDetalleIncidencia = '/tecnico/incidencia-detalle';

  // ADMIN / SUPERVISOR
  static const String adminHome = '/admin/home';
  static const String adminReportes = '/admin/reportes';
  static const String adminAsignar = '/admin/asignar';
}
