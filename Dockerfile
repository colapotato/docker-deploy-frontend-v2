FROM node:22-alpine AS build-stage
RUN npm install -g pnpm
RUN pnpm config set registry https://registry.npmmirror.com
RUN pnpm config set unsafe-perm true

WORKDIR /app
# 拷贝锁文件+包描述（仓库已存在pnpm-lock.yaml）
COPY package.json pnpm-lock.yaml ./
# 忽略所有依赖postinstall脚本，彻底避开esbuild/vue-demi拦截
RUN pnpm install --frozen-lockfile --ignore-scripts

COPY . .
ARG BUILD_MODE=production
RUN pnpm run build -- --mode ${BUILD_MODE}

# Nginx静态服务阶段
FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]