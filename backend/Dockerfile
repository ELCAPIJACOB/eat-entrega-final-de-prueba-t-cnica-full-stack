FROM node:18-alpine

WORKDIR /app

# Copiar archivos de dependencias primero (mejor cache de Docker)
COPY package*.json ./

RUN npm install --omit=dev

# Copiar código fuente
COPY . .

EXPOSE 3000

CMD ["node", "src/index.js"]
