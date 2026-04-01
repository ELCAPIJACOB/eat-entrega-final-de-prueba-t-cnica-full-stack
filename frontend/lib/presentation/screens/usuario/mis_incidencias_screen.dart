import 'package:flutter/material.dart';
import '../../../core/constants/route_names.dart';
import '../../../data/models/incidencia.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/incidencia_card.dart';

class MisIncidenciasScreen extends StatefulWidget {
  const MisIncidenciasScreen({super.key});

  @override
  State<MisIncidenciasScreen> createState() => _MisIncidenciasScreenState();
}

class _MisIncidenciasScreenState extends State<MisIncidenciasScreen> {
  List<Incidencia> _incidencias = [];
  bool _loading = true;
  String? _error;
  String? _filtroEstatus;
  String? _userName;

  final _estatuses = ['ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA'];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _load();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.instance.getCurrentUser();
    if (mounted) setState(() => _userName = user?.nombre);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await IncidenciaService.instance
          .listarMisIncidencias(estatus: _filtroEstatus);
      if (mounted) setState(() { _incidencias = list; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mis Incidencias', style: TextStyle(fontSize: 17)),
            if (_userName != null)
              Text(_userName!, style: const TextStyle(fontSize: 12, color: Color(0xFF8892B0))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).pushNamed(RouteNames.usuarioCrearIncidencia);
          _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva'),
      ),
      body: Column(
        children: [
          // Filtros
          _FiltroBar(
            estatuses: _estatuses,
            selected: _filtroEstatus,
            onSelected: (v) {
              setState(() => _filtroEstatus = v);
              _load();
            },
          ),
          // Lista
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D5AFE)))
                : _error != null
                    ? _ErrorView(message: _error!, onRetry: _load)
                    : _incidencias.isEmpty
                        ? const _EmptyView()
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: const Color(0xFF3D5AFE),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _incidencias.length,
                              itemBuilder: (ctx, i) => IncidenciaCard(
                                incidencia: _incidencias[i],
                                detailRoute: RouteNames.usuarioDetalleIncidencia,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FiltroBar extends StatelessWidget {
  final List<String> estatuses;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _FiltroBar({required this.estatuses, this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _chip('Todos', null),
          ...estatuses.map((e) => _chip(e, e)),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : const Color(0xFF8892B0))),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        selectedColor: const Color(0xFF3D5AFE),
        checkmarkColor: Colors.white,
        backgroundColor: const Color(0xFF1A1D2E),
        side: BorderSide(color: isSelected ? const Color(0xFF3D5AFE) : const Color(0xFF2E3250)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_outlined, color: Color(0xFF4A5568), size: 52),
        SizedBox(height: 12),
        Text('No tienes incidencias aún', style: TextStyle(color: Color(0xFF8892B0))),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, color: Color(0xFFCF6679), size: 48),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: Color(0xFF8892B0))),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    ),
  );
}
