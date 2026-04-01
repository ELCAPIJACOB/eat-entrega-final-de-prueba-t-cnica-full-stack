import 'package:flutter/material.dart';
import '../../../data/models/incidencia.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/log_entry.dart';

class DetalleIncidenciaUsuarioScreen extends StatefulWidget {
  final int incidenciaId;
  const DetalleIncidenciaUsuarioScreen({super.key, required this.incidenciaId});

  @override
  State<DetalleIncidenciaUsuarioScreen> createState() =>
      _DetalleIncidenciaUsuarioScreenState();
}

class _DetalleIncidenciaUsuarioScreenState
    extends State<DetalleIncidenciaUsuarioScreen> {
  Incidencia? _incidencia;
  bool _loading = true;
  String? _error;
  final _comentarioCtrl = TextEditingController();
  bool _sendingComment = false;

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
          .verDetalleUsuario(widget.incidenciaId);
      if (mounted) setState(() { _incidencia = inc; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  Future<void> _sendComment() async {
    final msg = _comentarioCtrl.text.trim();
    if (msg.isEmpty) return;
    setState(() => _sendingComment = true);
    try {
      await IncidenciaService.instance
          .comentarUsuario(widget.incidenciaId, msg);
      _comentarioCtrl.clear();
      await _load();
    } catch (_) {} finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(title: const Text('Detalle de Incidencia')),
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
                // Header card
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
                            child: Text(
                              inc.titulo,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(estatus: inc.estatus, fontSize: 12),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        inc.descripcion,
                        style: const TextStyle(
                            color: Color(0xFF8892B0), fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (inc.prioridad != null) PriorityBadge(prioridad: inc.prioridad),
                          if (inc.categoria != null)
                            _InfoChip(icon: Icons.folder_outlined, label: inc.categoria!),
                          if (inc.tecnico != null)
                            _InfoChip(icon: Icons.engineering_outlined, label: inc.tecnico!.nombre),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bitácora
                const Text(
                  'Bitácora',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (logs.isEmpty)
                  const Text('Sin registros en bitácora.',
                      style: TextStyle(color: Color(0xFF8892B0)))
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

        // Comment input
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1D2E),
            border: Border(top: BorderSide(color: Color(0xFF2E3250))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _comentarioCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Agregar comentario...',
                    hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                    filled: true,
                    fillColor: const Color(0xFF252840),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              _sendingComment
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                          color: Color(0xFF3D5AFE), strokeWidth: 2.5))
                  : IconButton.filled(
                      icon: const Icon(Icons.send_rounded),
                      onPressed: _sendComment,
                      style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF3D5AFE)),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFF252840),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFF8892B0)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 11)),
      ],
    ),
  );
}
