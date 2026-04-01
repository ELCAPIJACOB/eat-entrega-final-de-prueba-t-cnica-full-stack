import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../core/constants/route_names.dart';
import '../data/services/auth_service.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/shared/splash_screen.dart';
import '../presentation/screens/shared/access_denied_screen.dart';
import '../presentation/screens/usuario/mis_incidencias_screen.dart';
import '../presentation/screens/usuario/crear_incidencia_screen.dart';
import '../presentation/screens/usuario/detalle_incidencia_usuario_screen.dart';
import '../presentation/screens/tecnico/incidencias_asignadas_screen.dart';
import '../presentation/screens/tecnico/detalle_incidencia_tecnico_screen.dart';
import '../presentation/screens/admin/dashboard_admin_screen.dart';
import '../presentation/screens/admin/reportes_screen.dart';
import '../presentation/screens/admin/asignar_tecnico_screen.dart';

/// Genera las rutas de la app manualmente (sin go_router / auto_route).
/// Usa un [GuardedScreen] wrapper para evaluación asíncrona de guards.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? RouteNames.splash;
  final args = settings.arguments;

  switch (name) {
    // ─── Públicas (sin guard) ─────────────────────────────────
    case RouteNames.splash:
      return _buildRoute(const SplashScreen(), settings);

    case RouteNames.login:
      return _buildRoute(const LoginScreen(), settings);

    case RouteNames.accessDenied:
      return _buildRoute(const AccessDeniedScreen(), settings);

    // ─── USUARIO ──────────────────────────────────────────────
    case RouteNames.usuarioHome:
      return _buildRoute(
        const GuardedScreen(
          allowedRoles: ['USUARIO'],
          child: MisIncidenciasScreen(),
        ),
        settings,
      );

    case RouteNames.usuarioCrearIncidencia:
      return _buildRoute(
        const GuardedScreen(
          allowedRoles: ['USUARIO'],
          child: CrearIncidenciaScreen(),
        ),
        settings,
      );

    case RouteNames.usuarioDetalleIncidencia:
      return _buildRoute(
        GuardedScreen(
          allowedRoles: const ['USUARIO'],
          child: DetalleIncidenciaUsuarioScreen(incidenciaId: args as int? ?? 0),
        ),
        settings,
      );

    // ─── TECNICO ──────────────────────────────────────────────
    case RouteNames.tecnicoHome:
      return _buildRoute(
        const GuardedScreen(
          allowedRoles: ['TECNICO'],
          child: IncidenciasAsignadasScreen(),
        ),
        settings,
      );

    case RouteNames.tecnicoDetalleIncidencia:
      return _buildRoute(
        GuardedScreen(
          allowedRoles: const ['TECNICO'],
          child: DetalleIncidenciaTecnicoScreen(incidenciaId: args as int? ?? 0),
        ),
        settings,
      );

    // ─── ADMIN / SUPERVISOR ───────────────────────────────────
    case RouteNames.adminHome:
      return _buildRoute(
        const GuardedScreen(
          allowedRoles: ['SUPERVISOR'],
          child: DashboardAdminScreen(),
        ),
        settings,
      );

    case RouteNames.adminReportes:
      return _buildRoute(
        const GuardedScreen(
          allowedRoles: ['SUPERVISOR'],
          child: ReportesScreen(),
        ),
        settings,
      );

    case RouteNames.adminAsignar:
      return _buildRoute(
        GuardedScreen(
          allowedRoles: const ['SUPERVISOR'],
          child: AsignarTecnicoScreen(incidenciaId: args as int? ?? 0),
        ),
        settings,
      );

    // ─── Ruta no encontrada ───────────────────────────────────
    default:
      return _buildRoute(
        Scaffold(
          backgroundColor: const Color(0xFF0F1117),
          body: Center(
            child: Text(
              'Ruta no encontrada: $name',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
        settings,
      );
  }
}

/// Construye un PageRoute con animación de slide + fade horizontal.
PageRouteBuilder<dynamic> _buildRoute(Widget screen, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, __, ___) => screen,
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Widget que evalúa los guards de forma asíncrona al montarse.
/// Si ENABLE_ROUTE_GUARDS = false, muestra el child directamente.
class GuardedScreen extends StatefulWidget {
  final List<String> allowedRoles;
  final Widget child;

  const GuardedScreen({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  State<GuardedScreen> createState() => _GuardedScreenState();
}

class _GuardedScreenState extends State<GuardedScreen> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runGuard());
  }

  Future<void> _runGuard() async {
    // En modo Smoke Tests, pasar directamente sin verificar
    if (!ENABLE_ROUTE_GUARDS) {
      if (mounted) setState(() => _checked = true);
      return;
    }

    final isLoggedIn = await AuthService.instance.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.login,
          (route) => false,
        );
      }
      return;
    }

    if (widget.allowedRoles.isNotEmpty) {
      final rol = await AuthService.instance.getRolFromToken();
      if (rol == null || !widget.allowedRoles.contains(rol)) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(RouteNames.accessDenied);
        }
        return;
      }
    }

    if (mounted) setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while guard is evaluating
    if (ENABLE_ROUTE_GUARDS && !_checked) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1117),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3D5AFE)),
        ),
      );
    }
    return widget.child;
  }
}
