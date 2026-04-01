import 'package:flutter/material.dart';
import '../../../core/constants/route_names.dart';
import '../../../data/models/incidencia.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/incidencia_card.dart';

class IncidenciasAsignadasScreen extends StatefulWidget {
  const IncidenciasAsignadasScreen({super.key});

  @override
  State<IncidenciasAsignadasScreen> createState() => _IncidenciasAsignadasScreenState();
}

class _IncidenciasAsignadasScreenState extends State<IncidenciasAsignadasScreen> {
  List<Incidencia> _incidencias = [];
  bool _loading = true;
  String? _error;
  String? _filtroEstatus;
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
      final list = await IncidenciaService.instance
          .listarIncidenciasAsignadas(estatus: _filtroEstatus);
      if (mounted) setState(() { _incidencias = list; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _incidencias
        .where((i) => ['ABIERTA', 'EN_PROCESO', 'EN_ESPERA'].contains(i.estatus))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mis Asignaciones', style: TextStyle(fontSize: 17)),
            if (_userName != null)
              Text(_userName!, style: const TextStyle(fontSize: 12, color: Color(0xFF8892B0))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Stats banner
          if (!_loading && _error == null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF3D5AFE).withOpacity(0.15), const Color(0xFF00E5FF).withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3D5AFE).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.engineering_outlined, color: Color(0xFF3D5AFE), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '$pendientes pendiente${pendientes != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${_incidencias.length} total',
                    style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
                  ),
                ],
              ),
            ),
          // Filtros
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                'Todos', 'ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA'
              ].map((s) {
                final val = s == 'Todos' ? null : s;
                final sel = _filtroEstatus == val;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s, style: TextStyle(fontSize: 11, color: sel ? Colors.white : const Color(0xFF8892B0))),
                    selected: sel,
                    onSelected: (_) { setState(() => _filtroEstatus = val); _load(); },
                    selectedColor: const Color(0xFF3D5AFE),
                    backgroundColor: const Color(0xFF1A1D2E),
                    side: BorderSide(color: sel ? const Color(0xFF3D5AFE) : const Color(0xFF2E3250)),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }).toList(),
            ),
          ),
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
                            Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 52),
                            SizedBox(height: 12),
                            Text('Sin incidencias asignadas', style: TextStyle(color: Color(0xFF8892B0))),
                          ]))
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: const Color(0xFF3D5AFE),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _incidencias.length,
                              itemBuilder: (_, i) => IncidenciaCard(
                                incidencia: _incidencias[i],
                                detailRoute: RouteNames.tecnicoDetalleIncidencia,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
