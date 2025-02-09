# build front-end
FROM node:20.18.0 AS frontend
ENV NODE_OPTIONS="--max-old-space-size=8192 --max-semi-space-size=8192"

RUN npm install pnpm -g --no-fund

WORKDIR /app

COPY ./package.json /app

COPY ./pnpm-lock.yaml /app

RUN pnpm install && npx update-browserslist-db@latest -y

COPY . /app

RUN pnpm run build

# build backend
FROM node:20 as backend
ENV NODE_OPTIONS="--max-old-space-size=16384"

RUN npm install pnpm -g

WORKDIR /app

COPY /service/package.json /app

COPY /service/pnpm-lock.yaml /app

RUN pnpm install

COPY /service /app

RUN pnpm build

# service
FROM node:20

RUN npm install pnpm -g

WORKDIR /app

COPY /service/package.json /app

COPY /service/pnpm-lock.yaml /app

RUN pnpm install --production && rm -rf /root/.npm /root/.pnpm-store /usr/local/share/.cache /tmp/*

COPY /service /app

COPY --from=frontend /app/dist /app/public

COPY --from=backend /app/build /app/build

EXPOSE 3002

CMD ["pnpm", "run", "prod"]
