const { Router } = require('express');
const { body, param, query } = require('express-validator');
const { verifyToken } = require('../middlewares/auth');
const { requireRole } = require('../middlewares/roles');
const { handleValidationErrors } = require('../middlewares/validate');
const {
  listarTodasIncidencias,
  asignarTecnico,
  actualizarIncidencia,
  inactivarIncidencia,
  obtenerReportes,
} = require('../controllers/admin.controller');

const router = Router();

// Todas las rutas de admin requieren JWT + rol SUPERVISOR
router.use(verifyToken, requireRole('SUPERVISOR'));

/**
 * GET /api/admin/incidencias
 */
router.get(
  '/incidencias',
  [
    query('estatus').optional().isIn(['ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA']),
    query('prioridad').optional().isIn(['BAJA', 'MEDIA', 'ALTA', 'CRITICA']),
    query('tecnico_id').optional().isInt(),
    query('fecha_desde').optional().isISO8601(),
    query('fecha_hasta').optional().isISO8601(),
    handleValidationErrors,
  ],
  listarTodasIncidencias
);

/**
 * GET /api/admin/reportes
 */
router.get(
  '/reportes',
  [
    query('fecha_desde').optional().isISO8601(),
    query('fecha_hasta').optional().isISO8601(),
    handleValidationErrors,
  ],
  obtenerReportes
);

/**
 * POST /api/admin/incidencias/:id/asignar
 */
router.post(
  '/incidencias/:id/asignar',
  [
    param('id').isInt({ min: 1 }).withMessage('ID inválido.'),
    body('tecnico_id').isInt({ min: 1 }).withMessage('tecnico_id es requerido y debe ser un número.'),
    handleValidationErrors,
  ],
  asignarTecnico
);

/**
 * PATCH /api/admin/incidencias/:id
 */
router.patch(
  '/incidencias/:id',
  [
    param('id').isInt({ min: 1 }).withMessage('ID inválido.'),
    body('estatus').optional().isIn(['ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA']),
    body('prioridad').optional().isIn(['BAJA', 'MEDIA', 'ALTA', 'CRITICA']),
    body('titulo').optional().isLength({ max: 200 }),
    handleValidationErrors,
  ],
  actualizarIncidencia
);

/**
 * DELETE /api/admin/incidencias/:id (soft delete)
 */
router.delete(
  '/incidencias/:id',
  [param('id').isInt({ min: 1 }).withMessage('ID inválido.'), handleValidationErrors],
  inactivarIncidencia
);

module.exports = router;
