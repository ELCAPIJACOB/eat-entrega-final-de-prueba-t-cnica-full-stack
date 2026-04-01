/**
 * Middleware global de manejo de errores.
 * Captura cualquier error que se pase a next(error) en la aplicación.
 * Siempre debe ser el ÚLTIMO middleware en registrarse.
 */
// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  console.error('❌ Error no manejado:', err.message);
  if (process.env.NODE_ENV === 'development') {
    console.error(err.stack);
  }

  // Errores de Sequelize de validación
  if (err.name === 'SequelizeValidationError') {
    return res.status(422).json({
      success: false,
      message: 'Error de validación en base de datos.',
      errors: err.errors.map((e) => ({ field: e.path, message: e.message })),
    });
  }

  // Errores de restricción única (email duplicado, etc.)
  if (err.name === 'SequelizeUniqueConstraintError') {
    return res.status(409).json({
      success: false,
      message: 'Conflicto: un registro con estos datos ya existe.',
      errors: err.errors.map((e) => ({ field: e.path, message: e.message })),
    });
  }

  // Errores de FK inválida
  if (err.name === 'SequelizeForeignKeyConstraintError') {
    return res.status(400).json({
      success: false,
      message: 'Referencia inválida: el recurso relacionado no existe.',
    });
  }

  // Error genérico
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'Error interno del servidor.',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = { errorHandler };
