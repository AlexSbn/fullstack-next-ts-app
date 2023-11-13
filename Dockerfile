FROM node:20-alpine AS base
WORKDIR /
COPY package.json .
COPY . .
RUN npm install 
#  --frozen-lockfile чтобы yarn.lock или package-lock.json не обновлялся при запуске yarn install (или npm install). 

FROM base AS builder
WORKDIR /
COPY --from=base /node_modules ./node_modules
COPY . .
# COPY package.json .
RUN npx prisma generate
RUN npm run build

# COPY next.config.js tsconfig.json config.ts util.ts middleware.ts ./

# COPY public ./public
# COPY lib ./lib
# COPY types ./types
# COPY app ./app
# COPY components ./components

# ENV NEXT_PUBLIC_API_HOST=blog.local
# ENV NEXT_PUBLIC_PROTOCOL=http

# RUN npm run build

FROM base AS release
# На данном этапе мы хотим поместить исходный код нашего приложения в образ докера, вот почему мы используем COPY.
# COPY --from=builder /frontend/.next ./.next
# COPY --from=builder /frontend/public ./public
# COPY --from=builder /frontend/package.json ./
COPY --from=builder /node_modules ./node_modules
COPY --from=builder . .
RUN npx prisma generate

EXPOSE 3000

ENTRYPOINT ["npm", "run", "migrate:start"] 
