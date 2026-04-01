const { Router } = require('express');
const { body } = require('express-validator');
const { login } = require('../controllers/auth.controller');
const { handleValidationErrors } = require('../middlewares/validate');

const router = Router();

/**
 * POST /api/auth/login
 */
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Ingresa un email válido.').normalizeEmail(),
    body('password').notEmpty().withMessage('La contraseña es requerida.').isLength({ min: 6 }).withMessage('La contraseña debe tener al menos 6 caracteres.'),
    handleValidationErrors,
  ],
  login
);

module.exports = router;
