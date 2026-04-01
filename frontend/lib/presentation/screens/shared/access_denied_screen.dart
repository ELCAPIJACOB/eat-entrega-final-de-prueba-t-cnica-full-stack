import 'package:flutter/material.dart';
import '../../../core/constants/route_names.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFCF6679).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFCF6679).withOpacity(0.4)),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFFCF6679), size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                'Acceso Denegado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No tienes permisos para acceder a esta sección.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8892B0), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(RouteNames.login, (_) => false),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Volver al Login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3D5AFE),
                  side: const BorderSide(color: Color(0xFF3D5AFE)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
