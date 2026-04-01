const { Router } = require('express');
const { body, param } = require('express-validator');
const { verifyToken } = require('../middlewares/auth');
const { requireRole } = require('../middlewares/roles');
const { handleValidationErrors } = require('../middlewares/validate');
const {
  crearIncidencia,
  listarMisIncidencias,
  verDetalleIncidencia,
  agregarComentario,
} = require('../controllers/usuario.controller');

const router = Router();

// Todas las rutas de usuario requieren JWT + rol USUARIO
router.use(verifyToken, requireRole('USUARIO'));

/**
 * POST /api/usuario/incidencias
 */
router.post(
  '/incidencias',
  [
    body('titulo').notEmpty().withMessage('El título es requerido.').isLength({ max: 200 }).withMessage('Máximo 200 caracteres.'),
    body('descripcion').notEmpty().withMessage('La descripción es requerida.'),
    body('prioridad').optional().isIn(['BAJA', 'MEDIA', 'ALTA', 'CRITICA']).withMessage('Prioridad inválida.'),
    body('categoria').optional().isString(),
    handleValidationErrors,
  ],
  crearIncidencia
);

/**
 * GET /api/usuario/incidencias
 */
router.get('/incidencias', listarMisIncidencias);

/**
 * GET /api/usuario/incidencias/:id
 */
router.get(
  '/incidencias/:id',
  [param('id').isInt({ min: 1 }).withMessage('ID inválido.'), handleValidationErrors],
  verDetalleIncidencia
);

/**
 * POST /api/usuario/incidencias/:id/comentarios
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
