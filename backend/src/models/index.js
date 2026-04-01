const sequelize = require('../config/sequelize');
const Usuario = require('./Usuario');
const Incidencia = require('./Incidencia');
const IncidenciaLog = require('./IncidenciaLog');
const Asignacion = require('./Asignacion');

// ─── Incidencia associations ───────────────────────────────────────────────
// Una incidencia pertenece al usuario que la creó
Incidencia.belongsTo(Usuario, { foreignKey: 'usuario_id', as: 'usuario' });
// Una incidencia puede tener un técnico asignado
Incidencia.belongsTo(Usuario, { foreignKey: 'tecnico_id', as: 'tecnico' });
// Un usuario puede crear muchas incidencias
Usuario.hasMany(Incidencia, { foreignKey: 'usuario_id', as: 'incidencias_creadas' });
// Un técnico puede tener muchas incidencias asignadas
Usuario.hasMany(Incidencia, { foreignKey: 'tecnico_id', as: 'incidencias_asignadas' });

// ─── IncidenciaLog associations ────────────────────────────────────────────
IncidenciaLog.belongsTo(Incidencia, { foreignKey: 'incidencia_id', as: 'incidencia' });
IncidenciaLog.belongsTo(Usuario, { foreignKey: 'autor_id', as: 'autor' });
Incidencia.hasMany(IncidenciaLog, { foreignKey: 'incidencia_id', as: 'logs' });

// ─── Asignacion associations ───────────────────────────────────────────────
Asignacion.belongsTo(Incidencia, { foreignKey: 'incidencia_id', as: 'incidencia' });
Asignacion.belongsTo(Usuario, { foreignKey: 'tecnico_id', as: 'tecnico' });
Asignacion.belongsTo(Usuario, { foreignKey: 'asignado_por', as: 'supervisor' });
Incidencia.hasMany(Asignacion, { foreignKey: 'incidencia_id', as: 'asignaciones' });

module.exports = {
  sequelize,
  Usuario,
  Incidencia,
  IncidenciaLog,
  Asignacion,
};
