// ─── 1. Dependencias ────────────────────────────────────────────────────────
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

// ─── 2. Base de datos ────────────────────────────────────────────────────────
const { sequelize } = require('./models');

// ─── 3. Middlewares y Rutas ──────────────────────────────────────────────────
const routes = require('./routes');
const { errorHandler } = require('./middlewares/errorHandler');

// ─── 4. App ──────────────────────────────────────────────────────────────────
const app = express();

// Seguridad HTTP
app.use(helmet());

// CORS: permite peticiones del front-end
app.use(cors({
  origin: '*', // TODO: Ojo, en producción cambiar estrictamente al dominio del frontend
  // origin: ['https://nexgen-app.com', 'https://admin.nexgen-app.com'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Logging de peticiones HTTP
if (process.env.NODE_ENV !== 'test') {
  // TODO: Si esto escala mucho, meter Winston para guardar los access.log en un archivo físico
  app.use(morgan('dev'));
}

// Parseo de JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── 5. Health check ─────────────────────────────────────────────────────────
app.get('/api', (req, res) => {
  res.json({
    success: true,
    mensaje: '🚀 API NexGen – Sistema de Gestión de Incidencias',
    version: '1.0.0',
    estado: 'OK',
    timestamp: new Date().toISOString(),
  });
});

// ─── 6. Rutas de la API ───────────────────────────────────────────────────────
app.use('/api', routes);

// ─── 7. Ruta 404 (recurso no encontrado) ─────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Ruta no encontrada: ${req.method} ${req.originalUrl}`,
  });
});

// ─── 8. Middleware de manejo global de errores ────────────────────────────────
app.use(errorHandler);

// ─── 9. Inicio del servidor ───────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Conexión a PostgreSQL establecida correctamente.');

    app.listen(PORT, () => {
      console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
      console.log(`📌 Ambiente: ${process.env.NODE_ENV || 'development'}`);
      console.log(`📋 API Health: http://localhost:${PORT}/api`);
    });
  } catch (error) {
    console.error('❌ No se pudo conectar a la base de datos:', error.message);
    process.exit(1);
  }
};

startServer();

module.exports = app; // para tests
