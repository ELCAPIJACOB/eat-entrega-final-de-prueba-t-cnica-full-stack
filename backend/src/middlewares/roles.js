/**
 * Middleware factory: Verifica que el usuario autenticado tenga uno de los roles permitidos.
 * Debe usarse DESPUÉS de verifyToken.
 * 
 * @param {...string} roles - Roles permitidos, e.g. 'SUPERVISOR', 'TECNICO'
 */
const requireRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'No autenticado.',
      });
    }

    if (!roles.includes(req.user.rol)) {
      return res.status(403).json({
        success: false,
        message: `Acceso denegado. Se requiere uno de los roles: ${roles.join(', ')}.`,
        tu_rol: req.user.rol,
      });
    }

    next();
  };
};

module.exports = { requireRole };
