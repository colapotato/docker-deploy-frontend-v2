FROM node:22-alpine AS build-stage
# 全局安装pnpm
RUN npm install -g pnpm
# 换国内源加速
RUN pnpm config set registry https://registry.npmmirror.com

WORKDIR /app
# 同时复制package.json + pnpm锁文件
COPY package.json pnpm-lock.yaml ./
# 严格根据锁文件安装
RUN pnpm install --frozen-lockfile

COPY . .
ARG BUILD_MODE=production
RUN pnpm run build -- --mode ${BUILD_MODE}

# 生产Nginx阶段不变
FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]