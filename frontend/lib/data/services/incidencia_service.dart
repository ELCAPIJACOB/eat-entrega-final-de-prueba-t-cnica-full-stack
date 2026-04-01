import '../models/incidencia.dart';
import '../models/incidencia_log.dart';
import '../models/usuario.dart';
import 'api_service.dart';

class IncidenciaService {
  IncidenciaService._();
  static final IncidenciaService instance = IncidenciaService._();

  // ─── USUARIO ─────────────────────────────────────────────────────────────

  Future<Incidencia> crearIncidencia({
    required String titulo,
    required String descripcion,
    String? categoria,
    String? prioridad,
  }) async {
    final response = await ApiService.instance.post('/usuario/incidencias', {
      'titulo': titulo,
      'descripcion': descripcion,
      if (categoria != null) 'categoria': categoria,
      if (prioridad != null) 'prioridad': prioridad,
    });
    return Incidencia.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<Incidencia>> listarMisIncidencias({String? estatus}) async {
    final query = estatus != null ? '?estatus=$estatus' : '';
    final response = await ApiService.instance.get('/usuario/incidencias$query');
    return (response['data'] as List<dynamic>)
        .map((e) => Incidencia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Incidencia> verDetalleUsuario(int id) async {
    final response = await ApiService.instance.get('/usuario/incidencias/$id');
    return Incidencia.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<IncidenciaLog> comentarUsuario(int id, String mensaje) async {
    final response = await ApiService.instance.post(
      '/usuario/incidencias/$id/comentarios',
      {'mensaje': mensaje},
    );
    return IncidenciaLog.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ─── TECNICO ─────────────────────────────────────────────────────────────

  Future<List<Incidencia>> listarIncidenciasAsignadas({String? estatus}) async {
    final query = estatus != null ? '?estatus=$estatus' : '';
    final response = await ApiService.instance.get('/tecnico/incidencias$query');
    return (response['data'] as List<dynamic>)
        .map((e) => Incidencia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Incidencia> verDetalleTecnico(int id) async {
    final response = await ApiService.instance.get('/tecnico/incidencias/$id');
    return Incidencia.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Incidencia> actualizarEstatusTecnico(
      int id, String estatus, String? comentario) async {
    final response = await ApiService.instance.patch(
      '/tecnico/incidencias/$id',
      {
        'estatus': estatus,
        if (comentario != null) 'comentario': comentario,
      },
    );
    return Incidencia.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<IncidenciaLog> comentarTecnico(int id, String mensaje) async {
    final response = await ApiService.instance.post(
      '/tecnico/incidencias/$id/comentarios',
      {'mensaje': mensaje},
    );
    return IncidenciaLog.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ─── ADMIN ───────────────────────────────────────────────────────────────

  Future<List<Incidencia>> listarTodasIncidencias({
    String? estatus,
    String? prioridad,
    int? tecnicoId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? activo,
  }) async {
    final params = <String, String>{};
    if (estatus != null) params['estatus'] = estatus;
    if (prioridad != null) params['prioridad'] = prioridad;
    if (tecnicoId != null) params['tecnico_id'] = tecnicoId.toString();
    if (fechaDesde != null) params['fecha_desde'] = fechaDesde.toIso8601String();
    if (fechaHasta != null) params['fecha_hasta'] = fechaHasta.toIso8601String();
    if (activo != null) params['activo'] = activo;

    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';
    final response = await ApiService.instance.get('/admin/incidencias$query');
    return (response['data'] as List<dynamic>)
        .map((e) => Incidencia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> asignarTecnico(int incidenciaId, int tecnicoId) async {
    await ApiService.instance
        .post('/admin/incidencias/$incidenciaId/asignar', {'tecnico_id': tecnicoId});
  }

  Future<Incidencia> actualizarIncidenciaAdmin(
      int id, Map<String, dynamic> campos) async {
    final response = await ApiService.instance.patch('/admin/incidencias/$id', campos);
    return Incidencia.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> inactivarIncidencia(int id) async {
    await ApiService.instance.delete('/admin/incidencias/$id');
  }

  Future<Map<String, dynamic>> obtenerReportes({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final params = <String, String>{};
    if (fechaDesde != null) params['fecha_desde'] = fechaDesde.toIso8601String();
    if (fechaHasta != null) params['fecha_hasta'] = fechaHasta.toIso8601String();
    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';
    final response = await ApiService.instance.get('/admin/reportes$query');
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<Usuario>> listarTecnicos() async {
    // Usamos el endpoint de admin con filtro de rol — retorna incidencias con
    // técnicos incrustados, pero para la lista de técnicos hacemos una consulta
    // de reportes y extraemos los únicos. Si prefieres, puedes agregar un endpoint
    // /admin/tecnicos al backend.
    final response = await ApiService.instance.get('/admin/reportes');
    final porTecnico =
        (response['data']['por_tecnico'] as List<dynamic>? ?? []);
    return porTecnico.map((t) {
      final tecData = (t['tecnico'] as Map<String, dynamic>?) ?? {};
      return Usuario(
        id: t['tecnico_id'] as int,
        nombre: tecData['nombre'] as String? ?? 'N/A',
        email: tecData['email'] as String? ?? '',
        rol: 'TECNICO',
      );
    }).toList();
  }
}
