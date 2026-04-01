import 'package:flutter/material.dart';
import '../../../data/models/incidencia_log.dart';

class LogEntry extends StatelessWidget {
  final IncidenciaLog log;
  final bool isFirst;
  final bool isLast;

  const LogEntry({
    super.key,
    required this.log,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final rolColor = _rolColor(log.autor?.rol);
    final date = log.createdAt;
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 12, color: const Color(0xFF2E3250)),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: rolColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: rolColor.withOpacity(0.4), blurRadius: 6)],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFF2E3250)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        log.autor?.nombre ?? 'Sistema',
                        style: TextStyle(
                          color: rolColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (log.autor?.rol != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: rolColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.autor!.rol,
                            style: TextStyle(color: rolColor, fontSize: 9),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        dateStr,
                        style: const TextStyle(
                            color: Color(0xFF4A5568), fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D2E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2E3250)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.mensaje,
                          style: const TextStyle(
                            color: Color(0xFFECEFF1),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        if (log.estatusNuevo != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.swap_horiz_rounded,
                                  size: 13, color: Color(0xFF8892B0)),
                              const SizedBox(width: 4),
                              Text(
                                'Nuevo estatus: ${log.estatusNuevo}',
                                style: const TextStyle(
                                  color: Color(0xFF8892B0),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _rolColor(String? rol) {
    switch (rol) {
      case 'SUPERVISOR':
        return const Color(0xFFFFD700);
      case 'TECNICO':
        return const Color(0xFF00E5FF);
      case 'USUARIO':
        return const Color(0xFF3D5AFE);
      default:
        return const Color(0xFF8892B0);
    }
  }
}
