import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String estatus;
  final double fontSize;

  const StatusBadge({super.key, required this.estatus, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = estatusColor(estatus);
    final label = _label(estatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _label(String e) {
    switch (e.toUpperCase()) {
      case 'ABIERTA': return 'Abierta';
      case 'EN_PROCESO': return 'En Proceso';
      case 'EN_ESPERA': return 'En Espera';
      case 'RESUELTA': return 'Resuelta';
      case 'CERRADA': return 'Cerrada';
      default: return e;
    }
  }
}

class PriorityBadge extends StatelessWidget {
  final String? prioridad;
  final double fontSize;

  const PriorityBadge({super.key, this.prioridad, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final p = prioridad ?? 'MEDIA';
    final color = prioridadColor(p);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p == 'CRITICA')
            Icon(Icons.warning_amber_rounded, size: fontSize + 2, color: color),
          if (p == 'CRITICA') const SizedBox(width: 3),
          Text(
            p,
            style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
