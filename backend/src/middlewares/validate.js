const { validationResult } = require('express-validator');

/**
 * Middleware: Revisa los resultados de express-validator.
 * Si hay errores de validación, responde con 422 y la lista de errores.
 * Si está todo OK, pasa al siguiente middleware.
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({
      success: false,
      message: 'Error de validación en los datos enviados.',
      errors: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
      })),
    });
  }
  next();
};

module.exports = { handleValidationErrors };
