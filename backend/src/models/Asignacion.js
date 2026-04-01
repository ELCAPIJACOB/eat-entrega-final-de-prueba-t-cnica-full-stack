const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Asignacion = sequelize.define('Asignacion', {
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
  tecnico_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'usuarios',
      key: 'id',
    },
  },
  asignado_por: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'usuarios',
      key: 'id',
    },
  },
}, {
  tableName: 'asignaciones',
  timestamps: true,
  underscored: true,
  updatedAt: false,
});

module.exports = Asignacion;
