const { Router } = require('express');
const { body, param } = require('express-validator');
const { verifyToken } = require('../middlewares/auth');
const { requireRole } = require('../middlewares/roles');
const { handleValidationErrors } = require('../middlewares/validate');
const {
  listarIncidenciasAsignadas,
  verDetalleIncidencia,
  actualizarEstatus,
  agregarComentario,
} = require('../controllers/tecnico.controller');

const router = Router();

// Todas las rutas de técnico requieren JWT + rol TECNICO
router.use(verifyToken, requireRole('TECNICO'));

/**
 * GET /api/tecnico/incidencias
 */
router.get('/incidencias', listarIncidenciasAsignadas);

/**
 * GET /api/tecnico/incidencias/:id
 */
router.get(
  '/incidencias/:id',
  [param('id').isInt({ min: 1 }).withMessage('ID inválido.'), handleValidationErrors],
  verDetalleIncidencia
);

/**
 * PATCH /api/tecnico/incidencias/:id
 */
router.patch(
  '/incidencias/:id',
  [
    param('id').isInt({ min: 1 }).withMessage('ID inválido.'),
    body('estatus').optional().isIn(['EN_PROCESO', 'EN_ESPERA', 'RESUELTA']).withMessage('Estatus no permitido para técnico.'),
    body('comentario').optional().isString(),
    handleValidationErrors,
  ],
  actualizarEstatus
);

/**
 * POST /api/tecnico/incidencias/:id/comentarios
 */
router.post(
  '/incidencias/:id/comentarios',
  [
    param('id').isInt({ min: 1 }).withMessage('ID inválido.'),
    body('mensaje').notEmpty().withMessage('El mensaje es requerido.'),
    handleValidationErrors,
  ],
  agregarComentario
);

module.exports = router;
