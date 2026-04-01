import 'package:flutter/material.dart';
import '../../../data/models/incidencia.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/log_entry.dart';

class DetalleIncidenciaTecnicoScreen extends StatefulWidget {
  final int incidenciaId;
  const DetalleIncidenciaTecnicoScreen({super.key, required this.incidenciaId});

  @override
  State<DetalleIncidenciaTecnicoScreen> createState() =>
      _DetalleIncidenciaTecnicoScreenState();
}

class _DetalleIncidenciaTecnicoScreenState
    extends State<DetalleIncidenciaTecnicoScreen> {
  Incidencia? _incidencia;
  bool _loading = true;
  String? _error;
  final _comentarioCtrl = TextEditingController();
  String? _nuevoEstatus;
  bool _updatingStatus = false;

  final _estatusPermitidos = ['EN_PROCESO', 'EN_ESPERA', 'RESUELTA'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final inc = await IncidenciaService.instance
          .verDetalleTecnico(widget.incidenciaId);
      if (mounted) {
        setState(() {
          _incidencia = inc;
          _loading = false;
          _nuevoEstatus = inc.estatus;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  Future<void> _updateStatus() async {
    if (_nuevoEstatus == null) return;
    setState(() => _updatingStatus = true);
    try {
      await IncidenciaService.instance.actualizarEstatusTecnico(
        widget.incidenciaId,
        _nuevoEstatus!,
        _comentarioCtrl.text.trim().isNotEmpty ? _comentarioCtrl.text.trim() : null,
      );
      _comentarioCtrl.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Incidencia actualizada'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFCF6679)),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(title: const Text('Detalle – Técnico')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D5AFE)))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFCF6679))))
              : _incidencia == null
                  ? const SizedBox()
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final inc = _incidencia!;
    final logs = inc.logs ?? [];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E3250)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(inc.titulo,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                          ),
                          StatusBadge(estatus: inc.estatus),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(inc.descripcion,
                          style: const TextStyle(
                              color: Color(0xFF8892B0), fontSize: 13, height: 1.5)),
                      const SizedBox(height: 12),
                      Row(children: [
                        PriorityBadge(prioridad: inc.prioridad),
                        const SizedBox(width: 8),
                        if (inc.usuario != null) ...[
                          const Icon(Icons.person_outline, size: 13, color: Color(0xFF8892B0)),
                          const SizedBox(width: 4),
                          Text(inc.usuario!.nombre,
                              style: const TextStyle(color: Color(0xFF8892B0), fontSize: 11)),
                        ],
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status update panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3D5AFE).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Actualizar Estado',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      // Status chips
                      Wrap(
                        spacing: 8,
                        children: _estatusPermitidos.map((e) {
                          final sel = _nuevoEstatus == e;
                          final color = _estatusColor(e);
                          return ChoiceChip(
                            label: Text(e.replaceAll('_', ' ')),
                            selected: sel,
                            onSelected: (_) => setState(() => _nuevoEstatus = e),
                            selectedColor: color.withOpacity(0.25),
                            labelStyle: TextStyle(
                              color: sel ? color : const Color(0xFF8892B0),
                              fontSize: 12,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                            ),
                            side: BorderSide(color: sel ? color : const Color(0xFF2E3250)),
                            backgroundColor: const Color(0xFF252840),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _comentarioCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Nota de trabajo (opcional)...',
                          hintStyle: TextStyle(color: Color(0xFF4A5568)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _updatingStatus ? null : _updateStatus,
                          icon: _updatingStatus
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Guardar Cambios'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bitácora
                const Text('Bitácora',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (logs.isEmpty)
                  const Text('Sin registros.', style: TextStyle(color: Color(0xFF8892B0)))
                else
                  ...logs.asMap().entries.map((entry) => LogEntry(
                        log: entry.value,
                        isFirst: entry.key == 0,
                        isLast: entry.key == logs.length - 1,
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _estatusColor(String e) {
    switch (e) {
      case 'EN_PROCESO': return const Color(0xFFFFC107);
      case 'EN_ESPERA': return const Color(0xFFFF9800);
      case 'RESUELTA': return const Color(0xFF4CAF50);
      default: return const Color(0xFF8892B0);
    }
  }
}
