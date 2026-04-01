import 'package:flutter/material.dart';
import '../../../core/constants/route_names.dart';
import '../../../data/models/incidencia.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/incidencia_card.dart';
import '../../widgets/status_badge.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  List<Incidencia> _incidencias = [];
  bool _loading = true;
  String? _error;
  String? _filtroEstatus;
  String? _filtroPrioridad;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _load();
  }

  Future<void> _loadUser() async {
    final u = await AuthService.instance.getCurrentUser();
    if (mounted) setState(() => _userName = u?.nombre);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await IncidenciaService.instance.listarTodasIncidencias(
        estatus: _filtroEstatus,
        prioridad: _filtroPrioridad,
      );
      if (mounted) setState(() { _incidencias = list; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  Future<void> _softDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        title: const Text('¿Inactivar incidencia?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'La incidencia será inactivada (soft delete). ¿Continuar?',
            style: TextStyle(color: Color(0xFF8892B0))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCF6679)),
            child: const Text('Inactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await IncidenciaService.instance.inactivarIncidencia(id);
      _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFCF6679)));
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Supervisor', style: TextStyle(fontSize: 16)),
            if (_userName != null)
              Text(_userName!, style: const TextStyle(fontSize: 11, color: Color(0xFF8892B0))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Reportes',
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.adminReportes),
          ),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          if (!_loading && _error == null)
            _StatsRow(incidencias: _incidencias),
          // Filters
          _FilterBar(
            filtroEstatus: _filtroEstatus,
            filtroPrioridad: _filtroPrioridad,
            onEstatusChanged: (v) { setState(() => _filtroEstatus = v); _load(); },
            onPrioridadChanged: (v) { setState(() => _filtroPrioridad = v); _load(); },
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D5AFE)))
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.cloud_off, color: Color(0xFFCF6679), size: 48),
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Color(0xFF8892B0))),
                        const SizedBox(height: 16),
                        OutlinedButton(onPressed: _load, child: const Text('Reintentar')),
                      ]))
                    : _incidencias.isEmpty
                        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.inbox_outlined, color: Color(0xFF4A5568), size: 52),
                            SizedBox(height: 12),
                            Text('Sin incidencias', style: TextStyle(color: Color(0xFF8892B0))),
                          ]))
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: const Color(0xFF3D5AFE),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _incidencias.length,
                              itemBuilder: (_, i) {
                                final inc = _incidencias[i];
                                return Stack(
                                  children: [
                                    IncidenciaCard(
                                      incidencia: inc,
                                      detailRoute: RouteNames.usuarioDetalleIncidencia,
                                      onTap: () => _showActions(context, inc),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, Incidencia inc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inc.titulo,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            StatusBadge(estatus: inc.estatus),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2E3250)),
            ListTile(
              leading: const Icon(Icons.engineering_outlined, color: Color(0xFF3D5AFE)),
              title: const Text('Asignar / Reasignar técnico',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .pushNamed(RouteNames.adminAsignar, arguments: inc.id)
                    .then((_) => _load());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFCF6679)),
              title: const Text('Inactivar (soft delete)',
                  style: TextStyle(color: Color(0xFFCF6679))),
              onTap: () {
                Navigator.pop(context);
                _softDelete(inc.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Incidencia> incidencias;

  const _StatsRow({required this.incidencias});

  @override
  Widget build(BuildContext context) {
    final abiertas = incidencias.where((i) => i.estatus == 'ABIERTA').length;
    final enProceso = incidencias.where((i) => i.estatus == 'EN_PROCESO').length;
    final criticas = incidencias.where((i) => i.prioridad == 'CRITICA').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _StatCard(label: 'Total', value: incidencias.length, color: const Color(0xFF3D5AFE)),
          const SizedBox(width: 8),
          _StatCard(label: 'Abiertas', value: abiertas, color: const Color(0xFF2196F3)),
          const SizedBox(width: 8),
          _StatCard(label: 'En proceso', value: enProceso, color: const Color(0xFFFFC107)),
          const SizedBox(width: 8),
          _StatCard(label: 'Críticas', value: criticas, color: const Color(0xFFF44336)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$value', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _FilterBar extends StatelessWidget {
  final String? filtroEstatus;
  final String? filtroPrioridad;
  final ValueChanged<String?> onEstatusChanged;
  final ValueChanged<String?> onPrioridadChanged;

  const _FilterBar({
    this.filtroEstatus,
    this.filtroPrioridad,
    required this.onEstatusChanged,
    required this.onPrioridadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _chip('Todos', null, filtroEstatus, onEstatusChanged),
          _chip('Abierta', 'ABIERTA', filtroEstatus, onEstatusChanged),
          _chip('En Proceso', 'EN_PROCESO', filtroEstatus, onEstatusChanged),
          _chip('En Espera', 'EN_ESPERA', filtroEstatus, onEstatusChanged),
          _chip('Resuelta', 'RESUELTA', filtroEstatus, onEstatusChanged),
          const SizedBox(width: 8, child: VerticalDivider(color: Color(0xFF2E3250), indent: 4, endIndent: 4)),
          _chip('⚡ Crítica', 'CRITICA', filtroPrioridad, onPrioridadChanged),
          _chip('🔴 Alta', 'ALTA', filtroPrioridad, onPrioridadChanged),
        ],
      ),
    );
  }

  Widget _chip(String label, String? val, String? selected, ValueChanged<String?> onTap) {
    final sel = selected == val;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: sel ? Colors.white : const Color(0xFF8892B0))),
        selected: sel,
        onSelected: (_) => onTap(val),
        selectedColor: const Color(0xFF3D5AFE),
        backgroundColor: const Color(0xFF1A1D2E),
        side: BorderSide(color: sel ? const Color(0xFF3D5AFE) : const Color(0xFF2E3250)),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
