import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_names.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación en vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const NexGenApp());
}

class NexGenApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const NexGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NexGen – Gestión de Incidencias',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,

      // Ruta inicial → Splash que decide a dónde ir según JWT/rol
      initialRoute: RouteNames.splash,

      // Router manual: sin go_router / auto_route / get
      onGenerateRoute: onGenerateRoute,
    );
  }
}
