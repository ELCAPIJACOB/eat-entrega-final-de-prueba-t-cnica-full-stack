import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/constants/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final isLoggedIn = await AuthService.instance.isLoggedIn();
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
      return;
    }

    final rol = await AuthService.instance.getRolFromToken();
    if (!mounted) return;

    switch (rol) {
      case 'USUARIO':
        Navigator.of(context).pushReplacementNamed(RouteNames.usuarioHome);
        break;
      case 'TECNICO':
        Navigator.of(context).pushReplacementNamed(RouteNames.tecnicoHome);
        break;
      case 'SUPERVISOR':
        Navigator.of(context).pushReplacementNamed(RouteNames.adminHome);
        break;
      default:
        await AuthService.instance.logout();
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D5AFE), Color(0xFF00E5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3D5AFE).withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 24),
                const Text(
                  'NexGen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gestión de Incidencias',
                  style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D5AFE)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
