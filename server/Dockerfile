FROM node:22-alpine

WORKDIR /app

# Dependencies
COPY package.json package-lock.json ./
RUN npm install --production

# App
COPY index.js ./
COPY admin/ ./admin/
COPY seed/ ./seed/
COPY surah_names.json ./

# Runtime data volume (persistent storage)
VOLUME /app/data

EXPOSE 3000

ENV NODE_ENV=production
ENV DATA_DIR=/app/data

CMD ["node", "index.js"]
