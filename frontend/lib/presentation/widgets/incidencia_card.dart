import 'package:flutter/material.dart';
import '../../../data/models/incidencia.dart';
import '../widgets/status_badge.dart';

class IncidenciaCard extends StatelessWidget {
  final Incidencia incidencia;
  final String detailRoute;
  final VoidCallback? onTap;

  const IncidenciaCard({
    super.key,
    required this.incidencia,
    required this.detailRoute,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () => Navigator.of(context).pushNamed(detailRoute, arguments: incidencia.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E3250)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      incidencia.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(estatus: incidencia.estatus),
                ],
              ),
              if (incidencia.categoria != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.folder_outlined,
                        size: 13, color: Color(0xFF8892B0)),
                    const SizedBox(width: 4),
                    Text(
                      incidencia.categoria!,
                      style: const TextStyle(
                          color: Color(0xFF8892B0), fontSize: 12),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                incidencia.descripcion,
                style: const TextStyle(
                    color: Color(0xFF8892B0), fontSize: 13, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  PriorityBadge(prioridad: incidencia.prioridad),
                  const Spacer(),
                  if (incidencia.tecnico != null) ...[
                    const Icon(Icons.engineering_outlined,
                        size: 12, color: Color(0xFF8892B0)),
                    const SizedBox(width: 4),
                    Text(
                      incidencia.tecnico!.nombre,
                      style: const TextStyle(
                          color: Color(0xFF8892B0), fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: Color(0xFF4A5568)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
