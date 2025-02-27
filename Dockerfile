FROM node:20-slim AS build

WORKDIR /usr/src/app

COPY package.json package-lock.json ./

RUN npm install
RUN npm audit fix || true

COPY . .

ENV NODE_ENV=production
#ARG VITE_SSE_ADDR
ENV VITE_REDIS_CONN_STRING=redis://redis:6379
ENV VITE_MQTT_HOST=mqtt
ENV VITE_MQTT_PORT=1883

# changed image to 20-slim as needed pacakge for arm32 musl (alpine) is not available
# @tailwindcss/oxide-linux-arm-musleabihf
RUN npm run build

FROM node:20-slim

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/build ./

# RUN echo '{"type": "module"}' > package.json
COPY package.json package-lock.json ./
RUN npm i redis async-mqtt
RUN npm audit fix || true

USER 1337:1337
ENV NODE_ENV=production
ENV VITE_SSE_ADDR=http://sse:8080
ENTRYPOINT [ "node", "/usr/src/app/index.js" ]
