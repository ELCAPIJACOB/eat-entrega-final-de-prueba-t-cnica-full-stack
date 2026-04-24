# – Sistema de Gestión y Reporte de Incidencias

> Prueba Técnica Full Stack – Flutter Mobile + Node.js/Express/PostgreSQL

---

## 📋 Tabla de Contenidos

1. [Estructura del Proyecto](#estructura)
2. [Credenciales de Prueba](#credenciales)
3. [Levantar con Docker (recomendado)](#docker)
4. [Levantar en Local (sin Docker)](#local)
5. [Ejecutar la App Flutter](#flutter)
6. [Guards de Rutas: Producción vs Smoke Tests](#guards)
7. [Colección de API (Postman)](#postman)
8. [Variables de Entorno](#env)

---

## 📁 Estructura del Proyecto {#estructura}

```
manuel-jacobo-test/
├── backend/                   # API Node.js + Express + Sequelize
│   ├── src/
│   │   ├── config/            # Configuración de base de datos (Sequelize)
│   │   ├── controllers/       # Lógica de negocio por rol
│   │   ├── middlewares/       # JWT, roles, validación, errores
│   │   ├── migrations/        # Migraciones de BD (4 tablas)
│   │   ├── models/            # Modelos Sequelize
│   │   ├── routes/            # Rutas organizadas por módulo
│   │   ├── seeders/           # Datos iniciales (usuarios + incidencias)
│   │   └── index.js           # Servidor Express principal
│   ├── api-collection.json    # Colección Postman
│   ├── Dockerfile
│   ├── .env.example
│   └── package.json
│
├── frontend/                  # Flutter Mobile
│   └── lib/
│       ├── core/              # Config, constantes, tema
│       ├── data/              # Modelos + servicios HTTP
│       ├── presentation/      # Pantallas y widgets
│       └── router/            # Router manual + Guards
│
├── docker-compose.yml         # PostgreSQL + API
└── README.md                  # Este archivo
```

---

## 🔑 Credenciales de Prueba {#credenciales}

| Rol        | Email                      | Contraseña     |
|------------|----------------------------|----------------|
| SUPERVISOR | supervisor@nexgen.com      | Admin1234!     |
| TÉCNICO    | ana.tecnico@nexgen.com     | Tecnico1234!   |
| TÉCNICO    | pedro.tecnico@nexgen.com   | Tecnico1234!   |
| USUARIO    | maria@nexgen.com           | Usuario1234!   |
| USUARIO    | juan@nexgen.com            | Usuario1234!   |

---

## 🐳 Levantar con Docker {#docker}

### Requisitos
- Docker Desktop instalado y corriendo

### Un solo comando

```bash
docker-compose up
```

> Esto levanta automáticamente:
> - **PostgreSQL 15** en puerto `5432`
> - **API NexGen** en puerto `3000`
> - Ejecuta migraciones y seeders automáticamente

### Verificar que funciona

```bash
curl http://localhost:3000/api
# Respuesta: { "success": true, "mensaje": "🚀 API NexGen..." }
```

### Detener

```bash
docker-compose down
# Para también borrar la base de datos:
docker-compose down -v
```

---

## 💻 Levantar en Local (sin Docker) {#local}

### Requisitos
- Node.js 18+ (`node --version`)
- PostgreSQL 14+ corriendo localmente
- npm

### 1. Configurar variables de entorno

```bash
cd backend
cp .env.example .env
# Edita .env con tus credenciales de PostgreSQL local
```

Valores por defecto en `.env`:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexgen_db
DB_USER=postgres
DB_PASSWORD=postgres123
JWT_SECRET=nexgen_super_secret_jwt_key_2024
```

### 2. Crear la base de datos en PostgreSQL

```sql
CREATE DATABASE nexgen_db;
```

### 3. Instalar dependencias

```bash
cd backend
npm install
```

### 4. Ejecutar migraciones

```bash
npm run db:migrate
# o: npx sequelize-cli db:migrate
```

### 5. Ejecutar seeders (datos iniciales)

```bash
npm run db:seed
# o: npx sequelize-cli db:seed:all
```

### 6. Iniciar servidor de desarrollo

```bash
npm run dev
# Servidor en: http://localhost:3000
```

### Comandos útiles de base de datos

```bash
# Deshacer todas las migraciones
npm run db:migrate:undo

# Deshacer todos los seeders
npm run db:seed:undo

# Reset completo (undo + migrate + seed)
npm run db:reset
```

---

## 📱 Ejecutar la App Flutter {#flutter}

### Requisitos
- Flutter SDK (stable) + Dart 3.x
- Android Studio con emulador configurado
- Un emulador Android corriendo

### 1. Instalar dependencias

```bash
cd frontend
flutter pub get
```

### 2. Verificar dispositivos disponibles

```bash
flutter devices
```

### 3. Ejecutar la app

```bash
flutter run
```

> **Nota:** La URL de la API para emulador Android apunta a `http://10.0.2.2:3000/api`.
> Si usas un dispositivo físico, cambia `API_BASE_URL` en `lib/core/config/app_config.dart`
> con la IP local de tu máquina (e.g. `http://192.168.1.X:3000/api`).

### Sobrescribir URL de API al correr

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000/api
```

---

## 🛡️ Guards de Rutas: Producción vs Smoke Tests {#guards}

### Modo Producción (por defecto)

Los guards verifican JWT y rol antes de mostrar cada pantalla:
- Sin token → redirige a Login
- Rol incorrecto → redirige a Acceso Denegado

```bash
flutter run
# ENABLE_ROUTE_GUARDS = true (por defecto)
```

### Modo Smoke Tests (sin autenticación)

Para navegar libremente por todas las pantallas sin token:

```bash
flutter run --dart-define=ENABLE_ROUTE_GUARDS=false
```

O cambiar directamente en `lib/core/config/app_config.dart`:

```dart
// Línea 14:
const bool ENABLE_ROUTE_GUARDS =
    bool.fromEnvironment('ENABLE_ROUTE_GUARDS', defaultValue: false); // ← cambiar a false
```

> En modo Smoke Tests, las llamadas a la API devolverán `401` si no hay token.
> El objetivo es revisar layouts, rutas y arquitectura de pantallas.

---

## 📬 Colección de API (Postman) {#postman}

El archivo `backend/api-collection.json` contiene todos los endpoints.

### Importar en Postman

1. Abrir Postman
2. `Import` → `File` → seleccionar `backend/api-collection.json`
3. Ejecutar **Login – Supervisor** primero (guarda el token automáticamente)
4. Ejecutar el resto de endpoints

### Endpoints disponibles

| Método | Ruta | Rol |
|--------|------|-----|
| POST | `/api/auth/login` | Público |
| POST | `/api/usuario/incidencias` | USUARIO |
| GET | `/api/usuario/incidencias` | USUARIO |
| GET | `/api/usuario/incidencias/:id` | USUARIO |
| POST | `/api/usuario/incidencias/:id/comentarios` | USUARIO |
| GET | `/api/tecnico/incidencias` | TECNICO |
| GET | `/api/tecnico/incidencias/:id` | TECNICO |
| PATCH | `/api/tecnico/incidencias/:id` | TECNICO |
| POST | `/api/tecnico/incidencias/:id/comentarios` | TECNICO |
| GET | `/api/admin/incidencias` | SUPERVISOR |
| POST | `/api/admin/incidencias/:id/asignar` | SUPERVISOR |
| PATCH | `/api/admin/incidencias/:id` | SUPERVISOR |
| DELETE | `/api/admin/incidencias/:id` | SUPERVISOR |
| GET | `/api/admin/reportes` | SUPERVISOR |

---

## ⚙️ Variables de Entorno {#env}

### Backend (`.env`)

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `PORT` | Puerto del servidor | `3000` |
| `NODE_ENV` | Ambiente | `development` |
| `DB_HOST` | Host de PostgreSQL | `localhost` |
| `DB_PORT` | Puerto de PostgreSQL | `5432` |
| `DB_NAME` | Nombre de la BD | `nexgen_db` |
| `DB_USER` | Usuario de BD | `postgres` |
| `DB_PASSWORD` | Contraseña de BD | `postgres123` |
| `JWT_SECRET` | Secreto para firmar JWT | *(cambiar en producción)* |
| `JWT_EXPIRES_IN` | Duración del token | `24h` |

### Flutter (`--dart-define`)

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `ENABLE_ROUTE_GUARDS` | Activa/desactiva guards | `true` |
| `API_BASE_URL` | URL base de la API | `http://10.0.2.2:3000/api` |

---

## 🏗️ Arquitectura

### Backend (MVC)

```
Rutas → Middlewares (auth, roles, validación) → Controladores → Modelos → PostgreSQL
```

### Flutter

```
main.dart → AppRouter (onGenerateRoute) → GuardedScreen → Screens
                                                          ↓
                                              Services (API calls)
                                                          ↓
                                              Models (Dart)
```

---

## 👤 Autor

**Manuel Jacobo** – Prueba Técnica Full Stack
