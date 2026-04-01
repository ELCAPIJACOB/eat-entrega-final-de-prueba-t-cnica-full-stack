'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    // Obtener IDs de usuarios (en orden de inserción: supervisor=1, ana=2, pedro=3, maria=4, juan=5)
    const usuarios = await queryInterface.sequelize.query(
      `SELECT id, email, rol FROM usuarios ORDER BY id ASC;`,
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );

    const supervisor = usuarios.find((u) => u.rol === 'SUPERVISOR');
    const [ana, pedro] = usuarios.filter((u) => u.rol === 'TECNICO');
    const [maria, juan] = usuarios.filter((u) => u.rol === 'USUARIO');

    const now = new Date();
    const dayAgo = (d) => new Date(now - d * 86400000);

    // ─── Incidencias ────────────────────────────────────────────────────────
    await queryInterface.bulkInsert('incidencias', [
      {
        titulo: 'Servidor de correo no responde',
        descripcion: 'El servidor SMTP dejó de responder desde esta mañana. Los usuarios no pueden enviar emails.',
        categoria: 'Infraestructura',
        prioridad: 'CRITICA',
        estatus: 'EN_PROCESO',
        usuario_id: maria.id,
        tecnico_id: ana.id,
        activo: true,
        fecha_creacion: dayAgo(3),
        fecha_cierre: null,
        created_at: dayAgo(3),
        updated_at: dayAgo(1),
      },
      {
        titulo: 'Impresora del área de contabilidad sin tinta',
        descripcion: 'La impresora HP LaserJet del piso 3 indica cartucho vacío.',
        categoria: 'Hardware',
        prioridad: 'BAJA',
        estatus: 'RESUELTA',
        usuario_id: maria.id,
        tecnico_id: pedro.id,
        activo: true,
        fecha_creacion: dayAgo(7),
        fecha_cierre: dayAgo(5),
        created_at: dayAgo(7),
        updated_at: dayAgo(5),
      },
      {
        titulo: 'Error al acceder al sistema ERP',
        descripcion: 'Al intentar iniciar sesión en el ERP aparece error 500. Afecta a todo el departamento de ventas.',
        categoria: 'Software',
        prioridad: 'ALTA',
        estatus: 'ABIERTA',
        usuario_id: juan.id,
        tecnico_id: null,
        activo: true,
        fecha_creacion: dayAgo(1),
        fecha_cierre: null,
        created_at: dayAgo(1),
        updated_at: dayAgo(1),
      },
      {
        titulo: 'Lentitud extrema en la red WiFi',
        descripcion: 'La red WiFi corporativa está muy lenta desde el lunes. El trabajo remoto es imposible.',
        categoria: 'Redes',
        prioridad: 'ALTA',
        estatus: 'EN_ESPERA',
        usuario_id: juan.id,
        tecnico_id: ana.id,
        activo: true,
        fecha_creacion: dayAgo(5),
        fecha_cierre: null,
        created_at: dayAgo(5),
        updated_at: dayAgo(2),
      },
      {
        titulo: 'Actualización de antivirus pendiente',
        descripcion: 'Las licencias de antivirus vencieron. Se requiere renovación urgente.',
        categoria: 'Seguridad',
        prioridad: 'MEDIA',
        estatus: 'CERRADA',
        usuario_id: maria.id,
        tecnico_id: pedro.id,
        activo: true,
        fecha_creacion: dayAgo(14),
        fecha_cierre: dayAgo(10),
        created_at: dayAgo(14),
        updated_at: dayAgo(10),
      },
      {
        titulo: 'Pantalla rota en laptop corporativa',
        descripcion: 'La pantalla de la laptop asignada al gerente presenta líneas horizontales.',
        categoria: 'Hardware',
        prioridad: 'MEDIA',
        estatus: 'ABIERTA',
        usuario_id: juan.id,
        tecnico_id: null,
        activo: false, // soft-deleted para demostración
        fecha_creacion: dayAgo(10),
        fecha_cierre: null,
        created_at: dayAgo(10),
        updated_at: dayAgo(8),
      },
    ]);

    // Obtener los IDs de las incidencias recién insertadas
    const incidencias = await queryInterface.sequelize.query(
      `SELECT id, titulo FROM incidencias ORDER BY id ASC;`,
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );

    const inc = (title) => incidencias.find((i) => i.titulo.includes(title.substring(0, 20))).id;

    const i1 = incidencias[0].id;
    const i2 = incidencias[1].id;
    const i3 = incidencias[2].id;
    const i4 = incidencias[3].id;
    const i5 = incidencias[4].id;

    // ─── Logs / Bitácora ────────────────────────────────────────────────────
    await queryInterface.bulkInsert('incidencia_logs', [
      // Incidencia 1: Servidor de correo
      {
        incidencia_id: i1,
        autor_id: maria.id,
        mensaje: 'Se reporta el problema: el servidor SMTP no responde desde las 8am.',
        estatus_nuevo: 'ABIERTA',
        created_at: dayAgo(3),
      },
      {
        incidencia_id: i1,
        autor_id: supervisor.id,
        mensaje: 'Asignado a técnico Ana Técnico para atención inmediata.',
        estatus_nuevo: null,
        created_at: dayAgo(2),
      },
      {
        incidencia_id: i1,
        autor_id: ana.id,
        mensaje: 'Se inició diagnóstico del servidor. Se encontró espacio en disco lleno al 98%.',
        estatus_nuevo: 'EN_PROCESO',
        created_at: dayAgo(1),
      },
      // Incidencia 2: Impresora
      {
        incidencia_id: i2,
        autor_id: maria.id,
        mensaje: 'Impresora HP sin tinta. Se necesita repuesto urgente.',
        estatus_nuevo: 'ABIERTA',
        created_at: dayAgo(7),
      },
      {
        incidencia_id: i2,
        autor_id: pedro.id,
        mensaje: 'Se reemplazó cartucho de tinta. Impresora operativa nuevamente.',
        estatus_nuevo: 'RESUELTA',
        created_at: dayAgo(5),
      },
      // Incidencia 3: ERP
      {
        incidencia_id: i3,
        autor_id: juan.id,
        mensaje: 'Error 500 al acceder al ERP. Afecta a todos los usuarios del área de ventas.',
        estatus_nuevo: 'ABIERTA',
        created_at: dayAgo(1),
      },
      // Incidencia 4: WiFi
      {
        incidencia_id: i4,
        autor_id: juan.id,
        mensaje: 'La red WiFi está muy lenta. Velocidad de descarga bajó de 50 Mbps a 2 Mbps.',
        estatus_nuevo: 'ABIERTA',
        created_at: dayAgo(5),
      },
      {
        incidencia_id: i4,
        autor_id: ana.id,
        mensaje: 'Se identificó que el router principal está saturado. Se solicitó equipo nuevo al proveedor.',
        estatus_nuevo: 'EN_ESPERA',
        created_at: dayAgo(3),
      },
      // Incidencia 5: Antivirus
      {
        incidencia_id: i5,
        autor_id: maria.id,
        mensaje: 'Las licencias de antivirus ESET vencieron el día de ayer.',
        estatus_nuevo: 'ABIERTA',
        created_at: dayAgo(14),
      },
      {
        incidencia_id: i5,
        autor_id: pedro.id,
        mensaje: 'Se realizó la renovación de 50 licencias. Instalación completada en todos los equipos.',
        estatus_nuevo: 'RESUELTA',
        created_at: dayAgo(12),
      },
      {
        incidencia_id: i5,
        autor_id: supervisor.id,
        mensaje: 'Incidencia cerrada. Proceso documentado para renovación anual.',
        estatus_nuevo: 'CERRADA',
        created_at: dayAgo(10),
      },
    ]);

    // ─── Asignaciones históricas ─────────────────────────────────────────────
    await queryInterface.bulkInsert('asignaciones', [
      {
        incidencia_id: i1,
        tecnico_id: ana.id,
        asignado_por: supervisor.id,
        created_at: dayAgo(2),
      },
      {
        incidencia_id: i2,
        tecnico_id: pedro.id,
        asignado_por: supervisor.id,
        created_at: dayAgo(7),
      },
      {
        incidencia_id: i4,
        tecnico_id: ana.id,
        asignado_por: supervisor.id,
        created_at: dayAgo(4),
      },
      {
        incidencia_id: i5,
        tecnico_id: pedro.id,
        asignado_por: supervisor.id,
        created_at: dayAgo(13),
      },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('asignaciones', null, {});
    await queryInterface.bulkDelete('incidencia_logs', null, {});
    await queryInterface.bulkDelete('incidencias', null, {});
  },
};
