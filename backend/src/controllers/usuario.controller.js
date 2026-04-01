const { Incidencia, IncidenciaLog, Usuario } = require('../models');
const { Op } = require('sequelize');

/**
 * POST /api/usuario/incidencias
 * Crea una nueva incidencia (rol: USUARIO).
 */
const crearIncidencia = async (req, res, next) => {
  try {
    const { titulo, descripcion, categoria, prioridad } = req.body;
    const usuario_id = req.user.id;

    const incidencia = await Incidencia.create({
      titulo,
      descripcion,
      categoria,
      prioridad,
      estatus: 'ABIERTA',
      usuario_id,
    });

    // Registrar log inicial
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: usuario_id,
      mensaje: `Incidencia creada: ${titulo}`,
      estatus_nuevo: 'ABIERTA',
    });

    return res.status(201).json({
      success: true,
      message: 'Incidencia creada exitosamente.',
      data: incidencia,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/usuario/incidencias
 * Lista incidencias del usuario autenticado (filtro por estatus opcional).
 */
const listarMisIncidencias = async (req, res, next) => {
  try {
    const { estatus } = req.query;
    const where = { usuario_id: req.user.id, activo: true };

    if (estatus) {
      const estatusValidos = ['ABIERTA', 'EN_PROCESO', 'EN_ESPERA', 'RESUELTA', 'CERRADA'];
      if (!estatusValidos.includes(estatus)) {
        return res.status(400).json({ success: false, message: 'Estatus no válido.' });
      }
      where.estatus = estatus;
    }

    const incidencias = await Incidencia.findAll({
      where,
      include: [
        {
          model: Usuario,
          as: 'tecnico',
          attributes: ['id', 'nombre', 'email'],
        },
      ],
      order: [['created_at', 'DESC']],
    });

    return res.status(200).json({
      success: true,
      data: incidencias,
      total: incidencias.length,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/usuario/incidencias/:id
 * Ver detalle de incidencia + bitácora (solo si pertenece al usuario).
 */
const verDetalleIncidencia = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, usuario_id: req.user.id, activo: true },
      include: [
        { model: Usuario, as: 'tecnico', attributes: ['id', 'nombre', 'email'] },
        {
          model: IncidenciaLog,
          as: 'logs',
          include: [{ model: Usuario, as: 'autor', attributes: ['id', 'nombre', 'rol'] }],
          order: [['created_at', 'ASC']],
        },
      ],
    });

    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada.' });
    }

    return res.status(200).json({ success: true, data: incidencia });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/usuario/incidencias/:id/comentarios
 * Agregar comentario en bitácora.
 */
const agregarComentario = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, usuario_id: req.user.id, activo: true },
    });

    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada.' });
    }

    const log = await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: req.body.mensaje,
      estatus_nuevo: null,
    });

    return res.status(201).json({ success: true, message: 'Comentario agregado.', data: log });
  } catch (error) {
    next(error);
  }
};

module.exports = { crearIncidencia, listarMisIncidencias, verDetalleIncidencia, agregarComentario };
