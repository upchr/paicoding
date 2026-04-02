# 前端环境配置说明

## 环境变量文件

| 文件 | 环境 | 用途 |
|------|------|------|
| `.env.development` | 开发环境 | 本地开发，API 指向 localhost |
| `.env.production` | 生产环境 | Docker/Nginx 部署，使用相对路径 |
| `.env.github-pages` | GitHub Pages | 静态部署到 GitHub Pages |

## 环境变量说明

| 变量 | 说明 | 示例 |
|------|------|------|
| `VITE_BASE_PATH` | 应用基础路径 | `/` 或 `/paicoding/` |
| `VITE_API_BASE_URL` | 后端 API 地址 | `http://localhost:8081` 或 `` (相对路径) |
| `VITE_WS_URL` | WebSocket 地址 | `ws://localhost:8081` |
| `VITE_EXCEL_PROCESS_URL` | Excel 处理服务地址 | `https://www.xuyifei.site:5000` |

## 构建命令

```bash
# 开发环境构建
npm run build:dev

# 生产环境构建（Docker/Nginx 部署）
npm run build:prod

# GitHub Pages 构建
npm run build:github

# 默认构建（使用 .env.production）
npm run build
```

## 部署场景

### 1. 本地开发
```bash
npm run dev
# 使用 .env.development 配置
# API: http://localhost:8081
```

### 2. Docker + Nginx 部署
```bash
npm run build:prod
# 使用 .env.production 配置
# API: 相对路径，通过 Nginx 代理
```

### 3. GitHub Pages 部署
```bash
npm run build:github
# 使用 .env.github-pages 配置
# base: /paicoding/
# API: 需要配置 CORS 的后端地址
```

## MIME Type 问题解决

如果遇到 `Failed to load module script: Expected a JavaScript-or-Wasm module script but the server responded with a MIME type of "text/html"` 错误：

### 原因
- 服务器找不到 JS 文件，返回了 404 页面（HTML）
- 通常是因为 `base` 路径配置错误

### 解决方案
1. 确保 `vite.config.ts` 中的 `base` 配置正确
2. GitHub Pages 部署时，`base` 应为 `/paicoding/`
3. Docker/Nginx 部署时，`base` 应为 `/`

### Nginx 配置示例
```nginx
server {
    listen 80;
    server_name your-domain.com;

    root /usr/share/nginx/html;
    index index.html;

    # SPA 路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API 代理
    location /api/ {
        proxy_pass http://backend:8081/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 修改配置文件

修改 `.env.*` 文件后，需要重新构建才能生效：

```bash
# 修改 .env.production 后
npm run build:prod
```
