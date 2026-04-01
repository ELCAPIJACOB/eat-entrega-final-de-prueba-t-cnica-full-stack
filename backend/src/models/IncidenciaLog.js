const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const IncidenciaLog = sequelize.define('IncidenciaLog', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  incidencia_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'incidencias',
      key: 'id',
    },
  },
  autor_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'usuarios',
      key: 'id',
    },
  },
  mensaje: {
    type: DataTypes.TEXT,
    allowNull: false,
    validate: {
      notEmpty: { msg: 'El mensaje no puede estar vacío' },
    },
  },
  estatus_nuevo: {
    type: DataTypes.STRING(30),
    allowNull: true,
  },
}, {
  tableName: 'incidencia_logs',
  timestamps: true,
  underscored: true,
  updatedAt: false,
});

module.exports = IncidenciaLog;
