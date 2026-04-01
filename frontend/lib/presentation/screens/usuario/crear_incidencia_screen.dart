import 'package:flutter/material.dart';
import '../../../data/services/incidencia_service.dart';
import '../../../data/services/api_service.dart';

class CrearIncidenciaScreen extends StatefulWidget {
  const CrearIncidenciaScreen({super.key});

  @override
  State<CrearIncidenciaScreen> createState() => _CrearIncidenciaScreenState();
}

class _CrearIncidenciaScreenState extends State<CrearIncidenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  String _prioridad = 'MEDIA';
  bool _loading = false;
  String? _error;

  final _prioridades = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      await IncidenciaService.instance.crearIncidencia(
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        categoria: _catCtrl.text.trim().isNotEmpty ? _catCtrl.text.trim() : null,
        prioridad: _prioridad,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Incidencia creada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(title: const Text('Nueva Incidencia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              TextFormField(
                controller: _tituloCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'El título es requerido' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'La descripción es requerida' : null,
              ),
              const SizedBox(height: 16),

              // Categoría
              TextFormField(
                controller: _catCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  prefixIcon: Icon(Icons.folder_outlined),
                  hintText: 'Hardware, Software, Redes...',
                ),
              ),
              const SizedBox(height: 16),

              // Prioridad
              const Text('Prioridad',
                  style: TextStyle(color: Color(0xFF8892B0), fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _prioridades.map((p) {
                  final selected = _prioridad == p;
                  final color = _prioridadColor(p);
                  return ChoiceChip(
                    label: Text(p),
                    selected: selected,
                    onSelected: (_) => setState(() => _prioridad = p),
                    selectedColor: color.withOpacity(0.25),
                    labelStyle: TextStyle(
                      color: selected ? color : const Color(0xFF8892B0),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    ),
                    side: BorderSide(
                        color: selected ? color : const Color(0xFF2E3250)),
                    backgroundColor: const Color(0xFF1A1D2E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  );
                }).toList(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCF6679).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFCF6679).withOpacity(0.5)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: Color(0xFFCF6679), fontSize: 13)),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Crear Incidencia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
