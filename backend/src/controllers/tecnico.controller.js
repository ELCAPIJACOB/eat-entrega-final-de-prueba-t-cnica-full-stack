const { Incidencia, IncidenciaLog, Usuario } = require('../models');

/**
 * GET /api/tecnico/incidencias
 * Lista incidencias asignadas al técnico autenticado.
 */
const listarIncidenciasAsignadas = async (req, res, next) => {
  try {
    const { estatus } = req.query;
    const where = { tecnico_id: req.user.id, activo: true };

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
        { model: Usuario, as: 'usuario', attributes: ['id', 'nombre', 'email'] },
      ],
      order: [
        // Ordenar por prioridad: CRITICA > ALTA > MEDIA > BAJA
        [require('sequelize').literal(`CASE prioridad WHEN 'CRITICA' THEN 1 WHEN 'ALTA' THEN 2 WHEN 'MEDIA' THEN 3 ELSE 4 END`), 'ASC'],
        ['created_at', 'DESC'],
      ],
    });

    return res.status(200).json({ success: true, data: incidencias, total: incidencias.length });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/tecnico/incidencias/:id
 * Ver detalle + bitácora de incidencia asignada al técnico.
 */
const verDetalleIncidencia = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, tecnico_id: req.user.id, activo: true },
      include: [
        { model: Usuario, as: 'usuario', attributes: ['id', 'nombre', 'email'] },
        {
          model: IncidenciaLog,
          as: 'logs',
          include: [{ model: Usuario, as: 'autor', attributes: ['id', 'nombre', 'rol'] }],
          order: [['created_at', 'ASC']],
        },
      ],
    });

    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada o no asignada a usted.' });
    }

    return res.status(200).json({ success: true, data: incidencia });
  } catch (error) {
    next(error);
  }
};

/**
 * PATCH /api/tecnico/incidencias/:id
 * Actualizar parcialmente estatus y/o agregar nota de trabajo.
 */
const actualizarEstatus = async (req, res, next) => {
  try {
    const { estatus, comentario } = req.body;
    const statutosPermitidos = ['EN_PROCESO', 'EN_ESPERA', 'RESUELTA'];

    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, tecnico_id: req.user.id, activo: true },
    });

    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada o no asignada a usted.' });
    }

    if (estatus && !statutosPermitidos.includes(estatus)) {
      return res.status(400).json({
        success: false,
        message: `El técnico solo puede establecer: ${statutosPermitidos.join(', ')}.`,
      });
    }

    const cambiados = {};
    if (estatus && estatus !== incidencia.estatus) {
      cambiados.estatus = estatus;
      if (estatus === 'RESUELTA') {
        cambiados.fecha_cierre = new Date();
      }
    }

    await incidencia.update(cambiados);

    // Registrar log
    const mensajeLog = comentario || `Estatus actualizado a: ${estatus}`;
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: mensajeLog,
      estatus_nuevo: estatus || null,
    });

    return res.status(200).json({ success: true, message: 'Incidencia actualizada.', data: incidencia });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/tecnico/incidencias/:id/comentarios
 * Agregar comentario sin cambiar estatus.
 */
const agregarComentario = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({
      where: { id: req.params.id, tecnico_id: req.user.id, activo: true },
    });

    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada o no asignada a usted.' });
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

module.exports = { listarIncidenciasAsignadas, verDetalleIncidencia, actualizarEstatus, agregarComentario };
