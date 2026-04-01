const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Usuario = sequelize.define('Usuario', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  nombre: {
    type: DataTypes.STRING(120),
    allowNull: false,
    validate: {
      notEmpty: { msg: 'El nombre no puede estar vacío' },
      len: { args: [2, 120], msg: 'El nombre debe tener entre 2 y 120 caracteres' },
    },
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: { msg: 'El correo electrónico ya está registrado' },
    validate: {
      isEmail: { msg: 'Debe ser un correo electrónico válido' },
    },
  },
  password_hash: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  rol: {
    type: DataTypes.ENUM('USUARIO', 'TECNICO', 'SUPERVISOR'),
    allowNull: false,
    defaultValue: 'USUARIO',
  },
}, {
  tableName: 'usuarios',
  timestamps: true,
  underscored: true,
});

module.exports = Usuario;
