# 前端构建阶段
FROM node:20.19-alpine AS builder

WORKDIR /app

# 复制 package.json 和锁文件
COPY package*.json ./

# 安装依赖
RUN npm ci

# 复制源代码并构建
COPY . .
RUN npm run build

# Nginx 生产环境阶段
FROM nginx:alpine

# 将构建产物复制到 nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 配置 nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
