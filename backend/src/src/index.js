// 1. IMPORTACIONES
// Traemos las herramientas que nos exige la prueba técnica
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// 2. CONFIGURACIÓN INICIAL
// Permite que el servidor lea variables ocultas (como contraseñas) más adelante
dotenv.config();

// Inicializamos la aplicación de Express
const app = express();

// 3. MIDDLEWARES GLOBALES
// cors() evita que el navegador o la app bloqueen la conexión por seguridad
app.use(cors()); 
// express.json() le enseña al servidor a entender datos en formato JSON (como los que mandará Flutter)
app.use(express.json()); 

// 4. RUTA DE PRUEBA (Smoke Test del servidor)
// Esto nos sirve para comprobar que el servidor responde antes de hacer cosas complejas
app.get('/api', (req, res) => {
    res.json({ 
        mensaje: '¡API de NexGen funcionando al 100%!',
        estado: 'OK'
    });
});

// 5. PUERTO Y ENCENDIDO
// Busca un puerto en las variables de entorno, o usa el 3000 por defecto
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo exitosamente en http://localhost:${PORT}`);
});