#!/bin/sh 
set -e 
# 默认后端地址
VITE_GRAPHQL_URI="${VITE_GRAPHQL_URI:-http://你的EC2 IP:8082/graphql}" 
VITE_SERVER_URI="${VITE_SERVER_URI:-http://你的EC2 IP:8082}" 
# 替换JS中的占位符
find /usr/share/nginx/html/assets -name '*.js' -exec sed -i \ 
"s|__VITE_GRAPHQL_URI_PLACEHOLDER__|${VITE_GRAPHQL_URI}|g" {} + 
find /usr/share/nginx/html/assets -name '*.js' -exec sed -i \
"s|__VITE_SERVER_URI_PLACEHOLDER__|${VITE_SERVER_URI}|g" {} + 
echo "后端接口配置完成"
exec nginx -g 'daemon off;'