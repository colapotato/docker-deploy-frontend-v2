FROM node:22-alpine AS build-stage
RUN npm install -g pnpm
RUN pnpm config set registry https://registry.npmmirror.com

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm approve-builds --all
RUN pnpm install --frozen-lockfile

COPY . .
ARG BUILD_MODE=production
RUN pnpm run build -- --mode ${BUILD_MODE}

FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]