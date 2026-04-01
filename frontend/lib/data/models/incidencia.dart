import 'usuario.dart';
import 'incidencia_log.dart';

class Incidencia {
  final int id;
  final String titulo;
  final String descripcion;
  final String? categoria;
  final String? prioridad;
  final String estatus;
  final int usuarioId;
  final int? tecnicoId;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaCierre;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Usuario? usuario;
  final Usuario? tecnico;
  final List<IncidenciaLog>? logs;

  const Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.categoria,
    this.prioridad,
    required this.estatus,
    required this.usuarioId,
    this.tecnicoId,
    required this.activo,
    this.fechaCreacion,
    this.fechaCierre,
    this.createdAt,
    this.updatedAt,
    this.usuario,
    this.tecnico,
    this.logs,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String?,
      prioridad: json['prioridad'] as String?,
      estatus: json['estatus'] as String,
      usuarioId: json['usuario_id'] as int,
      tecnicoId: json['tecnico_id'] as int?,
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'] as String)
          : null,
      fechaCierre: json['fecha_cierre'] != null
          ? DateTime.tryParse(json['fecha_cierre'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      usuario: json['usuario'] != null
          ? Usuario.fromJson(json['usuario'] as Map<String, dynamic>)
          : null,
      tecnico: json['tecnico'] != null
          ? Usuario.fromJson(json['tecnico'] as Map<String, dynamic>)
          : null,
      logs: json['logs'] != null
          ? (json['logs'] as List<dynamic>)
              .map((l) => IncidenciaLog.fromJson(l as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
