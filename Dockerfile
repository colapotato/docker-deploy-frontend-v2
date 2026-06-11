FROM node:22-alpine AS build-stage
RUN npm install -g pnpm
RUN pnpm config set registry https://registry.npmmirror.com
# 全局关闭pnpm构建脚本拦截
RUN pnpm config set ignore-builds false
RUN pnpm config set unsafe-perm true

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
# 安装时跳过构建脚本校验
RUN pnpm install --frozen-lockfile --ignore-builds

COPY . .
ARG BUILD_MODE=production
RUN pnpm run build -- --mode ${BUILD_MODE}

FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]