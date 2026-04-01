'use strict';

const bcrypt = require('bcryptjs');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    const salt = await bcrypt.genSalt(10);

    const hashPassword = async (plaintext) => bcrypt.hash(plaintext, salt);

    await queryInterface.bulkInsert('usuarios', [
      {
        nombre: 'Carlos Supervisor',
        email: 'supervisor@nexgen.com',
        password_hash: await hashPassword('Admin1234!'),
        rol: 'SUPERVISOR',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        nombre: 'Ana Técnico',
        email: 'ana.tecnico@nexgen.com',
        password_hash: await hashPassword('Tecnico1234!'),
        rol: 'TECNICO',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        nombre: 'Pedro Técnico',
        email: 'pedro.tecnico@nexgen.com',
        password_hash: await hashPassword('Tecnico1234!'),
        rol: 'TECNICO',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        nombre: 'María Usuaria',
        email: 'maria@nexgen.com',
        password_hash: await hashPassword('Usuario1234!'),
        rol: 'USUARIO',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        nombre: 'Juan Usuario',
        email: 'juan@nexgen.com',
        password_hash: await hashPassword('Usuario1234!'),
        rol: 'USUARIO',
        created_at: new Date(),
        updated_at: new Date(),
      },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('usuarios', null, {});
  },
};
