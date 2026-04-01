import 'package:flutter/material.dart';
import '../../../data/models/usuario.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';

class AsignarTecnicoScreen extends StatefulWidget {
  final int incidenciaId;
  const AsignarTecnicoScreen({super.key, required this.incidenciaId});

  @override
  State<AsignarTecnicoScreen> createState() => _AsignarTecnicoScreenState();
}

class _AsignarTecnicoScreenState extends State<AsignarTecnicoScreen> {
  List<Usuario> _tecnicos = [];
  bool _loading = true;
  bool _assigning = false;
  String? _error;
  int? _selectedTecnicoId;

  @override
  void initState() {
    super.initState();
    _loadTecnicos();
  }

  Future<void> _loadTecnicos() async {
    try {
      final list = await IncidenciaService.instance.listarTecnicos();
      if (mounted) setState(() { _tecnicos = list; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  Future<void> _asignar() async {
    if (_selectedTecnicoId == null) return;
    setState(() => _assigning = true);
    try {
      await IncidenciaService.instance.asignarTecnico(
          widget.incidenciaId, _selectedTecnicoId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Técnico asignado correctamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFCF6679)),
        );
      }
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(title: const Text('Asignar Técnico')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D5AFE)))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFCF6679))))
              : Column(
                  children: [
                    Expanded(
                      child: _tecnicos.isEmpty
                          ? const Center(
                              child: Text('No hay técnicos disponibles',
                                  style: TextStyle(color: Color(0xFF8892B0))))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _tecnicos.length,
                              itemBuilder: (_, i) {
                                final tec = _tecnicos[i];
                                final sel = _selectedTecnicoId == tec.id;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTecnicoId = tec.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? const Color(0xFF3D5AFE).withOpacity(0.15)
                                          : const Color(0xFF1A1D2E),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: sel
                                            ? const Color(0xFF3D5AFE)
                                            : const Color(0xFF2E3250),
                                        width: sel ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color(0xFF3D5AFE).withOpacity(0.2),
                                          child: Text(
                                            tec.nombre.isNotEmpty
                                                ? tec.nombre[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                color: Color(0xFF3D5AFE),
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(tec.nombre,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600)),
                                              Text(tec.email,
                                                  style: const TextStyle(
                                                      color: Color(0xFF8892B0),
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        if (sel)
                                          const Icon(Icons.check_circle_rounded,
                                              color: Color(0xFF3D5AFE), size: 22),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_selectedTecnicoId == null || _assigning)
                              ? null
                              : _asignar,
                          child: _assigning
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text('Confirmar Asignación'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
