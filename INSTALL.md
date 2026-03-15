# 安装和运行指南

## 前置条件

- Node.js >= 16.0.0
- npm >= 8.0.0

## 安装步骤

1. 进入项目目录
```bash
cd csdn-customer-web
```

2. 安装依赖
```bash
npm install
```

3. 启动开发服务器
```bash
npm run dev
```

4. 访问应用
打开浏览器访问: http://localhost:3001

## 环境配置

### 开发环境
确保 `.env.development` 文件配置正确:
```
VITE_API_BASE_URL=http://localhost:8080
```

### 生产环境
修改 `.env.production` 文件:
```
VITE_API_BASE_URL=https://your-production-domain.com
```

## 构建生产版本

```bash
npm run build
```

构建完成后，`dist` 目录包含所有生产文件。

## 部署

### 方式1: Nginx部署

将 `dist` 目录复制到服务器:

```bash
scp -r dist/* user@server:/path/to/nginx/html/
```

Nginx配置示例:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    root /path/to/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 方式2: 静态托管

将 `dist` 目录上传到静态托管服务:
- Vercel
- Netlify
- GitHub Pages
- 阿里云OSS

## 常见问题

### Q: npm install 失败?
A: 尝试清除缓存:
```bash
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### Q: 开发服务器启动失败?
A: 检查端口3001是否被占用，或修改 `vite.config.ts` 中的端口配置

### Q: API请求失败?
A: 确保后端服务正常运行，检查环境变量配置

### Q: 生产环境404?
A: 确保Nginx配置了 `try_files $uri $uri/ /index.html;`
