import 'package:flutter/material.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await IncidenciaService.instance.obtenerReportes();
      if (mounted) setState(() { _data = data; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Reportes Métricas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D5AFE)))
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.cloud_off, color: Color(0xFFCF6679), size: 48),
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Color(0xFF8892B0))),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: _load, child: const Text('Reintentar')),
                  ]))
              : _data == null
                  ? const SizedBox()
                  : _buildReportes(),
    );
  }

  Widget _buildReportes() {
    final d = _data!;
    final total = d['total_incidencias'] as int? ?? 0;
    final porEstatus = (d['por_estatus'] as List<dynamic>? ?? []);
    final porPrioridad = (d['por_prioridad'] as List<dynamic>? ?? []);
    final porTecnico = (d['por_tecnico'] as List<dynamic>? ?? []);

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF3D5AFE),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF3D5AFE).withOpacity(0.2), const Color(0xFF00E5FF).withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3D5AFE).withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Text('$total',
                      style: const TextStyle(
                          color: Color(0xFF3D5AFE),
                          fontSize: 48,
                          fontWeight: FontWeight.w800)),
                  const Text('Total de Incidencias',
                      style: TextStyle(color: Color(0xFF8892B0), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Por estatus
            _SectionTitle(title: 'Por Estatus', icon: Icons.donut_large_outlined),
            const SizedBox(height: 10),
            ...porEstatus.map((e) {
              final estatus = e['estatus'] as String? ?? '';
              final count = int.tryParse(e['total'].toString()) ?? 0;
              final pct = total > 0 ? count / total : 0.0;
              final color = _estatusColor(estatus);
              return _BarRow(label: estatus, count: count, pct: pct, color: color);
            }),
            const SizedBox(height: 20),

            // Por prioridad
            _SectionTitle(title: 'Por Prioridad', icon: Icons.priority_high_rounded),
            const SizedBox(height: 10),
            ...porPrioridad.map((e) {
              final prioridad = e['prioridad'] as String? ?? '';
              final count = int.tryParse(e['total'].toString()) ?? 0;
              final pct = total > 0 ? count / total : 0.0;
              final color = _prioridadColor(prioridad);
              return _BarRow(label: prioridad, count: count, pct: pct, color: color);
            }),
            const SizedBox(height: 20),

            // Por técnico
            _SectionTitle(title: 'Por Técnico', icon: Icons.engineering_outlined),
            const SizedBox(height: 10),
            if (porTecnico.isEmpty)
              const Text('Sin datos de técnicos.',
                  style: TextStyle(color: Color(0xFF8892B0)))
            else
              ...porTecnico.map((t) {
                final nombre = (t['tecnico']?['nombre'] as String?) ?? 'Técnico';
                final asignadas = int.tryParse(t['total_asignadas'].toString()) ?? 0;
                final resueltas = int.tryParse(t['resueltas'].toString()) ?? 0;
                final pendientes = int.tryParse(t['pendientes'].toString()) ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E3250)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MiniStat(label: 'Asignadas', value: asignadas, color: const Color(0xFF3D5AFE)),
                          const SizedBox(width: 12),
                          _MiniStat(label: 'Resueltas', value: resueltas, color: const Color(0xFF4CAF50)),
                          const SizedBox(width: 12),
                          _MiniStat(label: 'Pendientes', value: pendientes, color: const Color(0xFFFFC107)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Color _estatusColor(String e) {
    switch (e) {
      case 'ABIERTA': return const Color(0xFF2196F3);
      case 'EN_PROCESO': return const Color(0xFFFFC107);
      case 'EN_ESPERA': return const Color(0xFFFF9800);
      case 'RESUELTA': return const Color(0xFF4CAF50);
      case 'CERRADA': return const Color(0xFF607D8B);
      default: return const Color(0xFF8892B0);
    }
  }

  Color _prioridadColor(String p) {
    switch (p) {
      case 'BAJA': return const Color(0xFF4CAF50);
      case 'MEDIA': return const Color(0xFF2196F3);
      case 'ALTA': return const Color(0xFFFF9800);
      case 'CRITICA': return const Color(0xFFF44336);
      default: return const Color(0xFF8892B0);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF3D5AFE)),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
    ],
  );
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count;
  final double pct;
  final Color color;
  const _BarRow({required this.label, required this.count, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.replaceAll('_', ' '),
                style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12)),
            Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: const Color(0xFF2E3250),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 10)),
    ],
  );
}
