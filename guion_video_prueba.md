# 🎬 Guion de Grabación: Video de Demostración

Ten este documento abierto a un lado de tu pantalla para que te sirva como "teleprompter" o guía paso a paso mientras grabas tu pantalla.

> [!TIP]
> **Cómo grabar tu pantalla en Windows:**
> Abre la **Herramienta Recortes** (Snipping Tool) buscando en el menú inicio, o presiona `Windows + Shift + R` (o `Win+Shift+S` y selecciona el ícono de cámara de video). Asígnele un área que cubra tu **Terminal** y tu **Emulador** (o ventana de la app en Flutter).

---

## 🛠️ Parte 1: Levantar el Entorno (Back-End)

1. Muestra en tu pantalla una terminal limpia.
2. Escribe y ejecuta el comando: 
   ```bash
   docker-compose up -d
   ```
3. Di al micrófono (o pon texto si no hablas): *"Aquí estamos levantando los contenedores de Postgres y de la API en Node.js."*
4. Abre **Docker Desktop** (o escribe `docker ps` en terminal) para mostrar que están en verde / status _Up_.
5. Escribe en la terminal:
   ```bash
   docker logs nexgen_api -f
   ```
6. Explica: *"Como vemos en los logs, las tablas y la base de datos se inicializaron, y el servidor está corriendo correctamente en el puerto 3000."* (Deja esta ventanita de logs visible de fondo para lo que sigue).

---

## 📱 Parte 2: Flujo del Usuario (Cliente)

1. Abre la aplicación de **Flutter** (Emulador o Web).
2. **Login:** Inicia sesión con las siguientes credenciales:
   * **Correo:** `maria@nexgen.com`
   * **Contraseña:** `Usuario1234!`
3. Ve a la pantalla de crear una incidencia. Escribe un título y una descripción.
4. Presiona el botón de crear.
5. **¡Importante!** Muestra la ventana de la terminal de logs que abriste en el paso 1. Muestra cómo apareció la petición `POST /api/incidencias`.
6. En la app, ve a "Mis Incidencias" (o equivalente) y abre el detalle de la que acabas de crear.
7. Cierra sesión en la App.

---

## 🔧 Parte 3: Flujo del Técnico

1. **Login:** Inicia sesión con el Técnico:
   * **Correo:** `ana.tecnico@nexgen.com`
   * **Contraseña:** `Tecnico1234!`
2. Visualiza las incidencias que tiene asignadas.
3. Entra al detalle de la incidencia que creaste.
4. Cambia el estado de la incidencia.
5. Agrega un comentario en esa pantalla.
6. Cierra sesión.

---

## 👔 Parte 4: Flujo del Admin / Supervisor

1. **Login:** Inicia sesión con el Administrador:
   * **Correo:** `supervisor@nexgen.com`
   * **Contraseña:** `Admin1234!`
2. Muestra que él puede ver TODAS las incidencias globales del sistema.
3. Abre la incidencia creada en el Paso 2 y localiza la opción de "Reasignar".
4. Asígnasela a otro técnico (por ejemplo de Ana a Pedro).
5. Cierra sesión en la App.

---

## 🔒 Parte 5: Validaciones de Seguridad (Breve)

1. **JWT:** Muestra el archivo de tu código frontend donde inyectas el `Bearer token` en los `Headers`, o muestra la pestaña "Network" (Red) si estás corriendo en Flutter Web para comprobar los headers.
2. **Restricción de Roles:** Menciona tu archivo `app_config.dart` donde tienes guardias de ruta, o intenta acceder a una vista de "Admin" desde la cuenta del "Usuario" para mostrar cómo es bloqueado por sistema.

**¡Fin de la grabación!**
