const { Incidencia, IncidenciaLog, Asignacion, Usuario } = require('../models');
const { Op, fn, col, literal } = require('sequelize');

/**
 * GET /api/admin/incidencias
 * Lista global con filtros (estatus, prioridad, tecnico_id, fechas).
 */
const listarTodasIncidencias = async (req, res, next) => {
  try {
    const { estatus, prioridad, tecnico_id, fecha_desde, fecha_hasta, activo } = req.query;
    const where = {};

    // Por defecto solo activas, a menos que se pida explícitamente
    if (activo === 'false') {
      where.activo = false;
    } else if (activo === 'all') {
      // sin filtro
    } else {
      where.activo = true;
    }

    if (estatus) where.estatus = estatus;
    if (prioridad) where.prioridad = prioridad;
    if (tecnico_id) where.tecnico_id = tecnico_id;
    if (fecha_desde || fecha_hasta) {
      where.fecha_creacion = {};
      if (fecha_desde) where.fecha_creacion[Op.gte] = new Date(fecha_desde);
      if (fecha_hasta) where.fecha_creacion[Op.lte] = new Date(fecha_hasta);
    }

    const incidencias = await Incidencia.findAll({
      where,
      include: [
        { model: Usuario, as: 'usuario', attributes: ['id', 'nombre', 'email'] },
        { model: Usuario, as: 'tecnico', attributes: ['id', 'nombre', 'email'] },
      ],
      order: [
        [literal(`CASE prioridad WHEN 'CRITICA' THEN 1 WHEN 'ALTA' THEN 2 WHEN 'MEDIA' THEN 3 ELSE 4 END`), 'ASC'],
        ['created_at', 'DESC'],
      ],
    });

    return res.status(200).json({ success: true, data: incidencias, total: incidencias.length });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/admin/incidencias/:id/asignar
 * Asignar o reasignar técnico a una incidencia.
 */
const asignarTecnico = async (req, res, next) => {
  try {
    const { tecnico_id } = req.body;
    const supervisorId = req.user.id;

    // Verificar que el técnico exista y tenga rol TECNICO
    const tecnico = await Usuario.findOne({ where: { id: tecnico_id, rol: 'TECNICO' } });
    if (!tecnico) {
      return res.status(404).json({ success: false, message: 'Técnico no encontrado.' });
    }

    const incidencia = await Incidencia.findOne({ where: { id: req.params.id, activo: true } });
    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada.' });
    }

    await incidencia.update({ tecnico_id, estatus: incidencia.estatus === 'ABIERTA' ? 'EN_PROCESO' : incidencia.estatus });

    // Registrar en historial de asignaciones
    await Asignacion.create({ incidencia_id: incidencia.id, tecnico_id, asignado_por: supervisorId });

    // Registrar en bitácora
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: supervisorId,
      mensaje: `Técnico asignado: ${tecnico.nombre} (${tecnico.email}).`,
      estatus_nuevo: incidencia.estatus === 'ABIERTA' ? 'EN_PROCESO' : null,
    });

    return res.status(200).json({ success: true, message: 'Técnico asignado exitosamente.', data: incidencia });
  } catch (error) {
    next(error);
  }
};

/**
 * PATCH /api/admin/incidencias/:id
 * Modificar campos puntuales (prioridad, categoría, estatus, etc.).
 */
const actualizarIncidencia = async (req, res, next) => {
  try {
    const camposPermitidos = ['titulo', 'descripcion', 'categoria', 'prioridad', 'estatus'];
    const updates = {};
    camposPermitidos.forEach((campo) => {
      if (req.body[campo] !== undefined) updates[campo] = req.body[campo];
    });

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ success: false, message: 'No se proporcionaron campos para actualizar.' });
    }

    const incidencia = await Incidencia.findOne({ where: { id: req.params.id, activo: true } });
    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada.' });
    }

    if (updates.estatus === 'CERRADA' || updates.estatus === 'RESUELTA') {
      updates.fecha_cierre = new Date();
    }

    await incidencia.update(updates);

    const camposCambiados = Object.keys(updates).join(', ');
    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: `Supervisor actualizó: ${camposCambiados}.`,
      estatus_nuevo: updates.estatus || null,
    });

    return res.status(200).json({ success: true, message: 'Incidencia actualizada.', data: incidencia });
  } catch (error) {
    next(error);
  }
};

/**
 * DELETE /api/admin/incidencias/:id
 * Soft delete: marca la incidencia como inactiva (activo = false).
 */
const inactivarIncidencia = async (req, res, next) => {
  try {
    const incidencia = await Incidencia.findOne({ where: { id: req.params.id, activo: true } });
    if (!incidencia) {
      return res.status(404).json({ success: false, message: 'Incidencia no encontrada o ya inactiva.' });
    }

    await incidencia.update({ activo: false });

    await IncidenciaLog.create({
      incidencia_id: incidencia.id,
      autor_id: req.user.id,
      mensaje: 'Incidencia inactivada por supervisor (soft delete).',
      estatus_nuevo: null,
    });

    return res.status(200).json({ success: true, message: 'Incidencia inactivada correctamente.' });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/admin/reportes
 * Métricas: por técnico, por estatus, por rango de fechas.
 */
const obtenerReportes = async (req, res, next) => {
  try {
    const { fecha_desde, fecha_hasta } = req.query;
    const whereBase = { activo: true };

    if (fecha_desde || fecha_hasta) {
      whereBase.fecha_creacion = {};
      if (fecha_desde) whereBase.fecha_creacion[Op.gte] = new Date(fecha_desde);
      if (fecha_hasta) whereBase.fecha_creacion[Op.lte] = new Date(fecha_hasta);
    }

    // Resumen por estatus
    const porEstatus = await Incidencia.findAll({
      where: whereBase,
      attributes: ['estatus', [fn('COUNT', col('id')), 'total']],
      group: ['estatus'],
      raw: true,
    });

    // Resumen por prioridad
    const porPrioridad = await Incidencia.findAll({
      where: whereBase,
      attributes: ['prioridad', [fn('COUNT', col('id')), 'total']],
      group: ['prioridad'],
      raw: true,
    });

    // Resumen por técnico
    const porTecnico = await Incidencia.findAll({
      where: { ...whereBase, tecnico_id: { [Op.not]: null } },
      attributes: [
        'tecnico_id',
        [fn('COUNT', col('Incidencia.id')), 'total_asignadas'],
        [fn('SUM', literal(`CASE WHEN estatus = 'RESUELTA' THEN 1 ELSE 0 END`)), 'resueltas'],
        [fn('SUM', literal(`CASE WHEN estatus IN ('ABIERTA','EN_PROCESO','EN_ESPERA') THEN 1 ELSE 0 END`)), 'pendientes'],
      ],
      include: [{ model: Usuario, as: 'tecnico', attributes: ['nombre', 'email'] }],
      group: ['tecnico_id', 'tecnico.id'],
      raw: true,
      nest: true,
    });

    // Total general
    const totalIncidencias = await Incidencia.count({ where: whereBase });

    return res.status(200).json({
      success: true,
      data: {
        total_incidencias: totalIncidencias,
        por_estatus: porEstatus,
        por_prioridad: porPrioridad,
        por_tecnico: porTecnico,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  listarTodasIncidencias,
  asignarTecnico,
  actualizarIncidencia,
  inactivarIncidencia,
  obtenerReportes,
};
