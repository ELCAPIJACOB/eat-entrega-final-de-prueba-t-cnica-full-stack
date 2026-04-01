import 'usuario.dart';

class IncidenciaLog {
  final int id;
  final int incidenciaId;
  final int autorId;
  final String mensaje;
  final String? estatusNuevo;
  final DateTime? createdAt;
  final Usuario? autor;

  const IncidenciaLog({
    required this.id,
    required this.incidenciaId,
    required this.autorId,
    required this.mensaje,
    this.estatusNuevo,
    this.createdAt,
    this.autor,
  });

  factory IncidenciaLog.fromJson(Map<String, dynamic> json) {
    return IncidenciaLog(
      id: json['id'] as int,
      incidenciaId: json['incidencia_id'] as int,
      autorId: json['autor_id'] as int,
      mensaje: json['mensaje'] as String,
      estatusNuevo: json['estatus_nuevo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      autor: json['autor'] != null
          ? Usuario.fromJson(json['autor'] as Map<String, dynamic>)
          : null,
    );
  }
}
