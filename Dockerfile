FROM node:24-slim AS builder

RUN apt-get update -y && apt-get install -y openssl ca-certificates

WORKDIR /usr/src/app

COPY package*.json ./
COPY prisma.config.ts ./
COPY prisma ./prisma/

RUN npm install
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
RUN npx prisma generate

COPY . .

RUN npm run build


FROM node:24-slim AS runner

RUN apt-get update -y && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

ENV NODE_ENV=production
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"

COPY package*.json ./
COPY prisma ./prisma/
COPY prisma.config.ts ./

RUN npm install --omit=dev
RUN npx prisma generate

COPY --from=builder /usr/src/app/dist ./dist

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
