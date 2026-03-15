# CSDN客户端Web应用

一个简单、响应式的客户使用页面，用于使用访问码下载CSDN会员资源。

## 功能特性

- 无需登录即可使用
- 响应式设计，完美适配手机端
- 纯HTML/CSS实现，便于迁移到微信小程序
- 支持打开HTML预览和下载压缩包
- 简洁的用户界面

## 技术栈

- Vue 3
- TypeScript
- Vite
- Element Plus
- 原生Fetch API（无需Axios）

## 项目结构

```
csdn-customer-web/
├── src/
│   ├── views/
│   │   └── UseCodeView.vue    # 主要页面
│   ├── router/
│   │   └── index.ts           # 路由配置
│   ├── App.vue                # 根组件
│   └── main.ts               # 入口文件
├── public/                   # 静态资源
├── index.html                # HTML模板
├── package.json             # 依赖配置
├── vite.config.ts           # Vite配置
└── tsconfig.json           # TypeScript配置
```

## 快速开始

### 安装依赖

```bash
cd csdn-customer-web
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3001

### 构建生产版本

```bash
npm run build
```

构建产物在 `dist` 目录

### 预览生产构建

```bash
npm run preview
```

## 环境配置

### 开发环境

`.env.development`
```
VITE_API_BASE_URL=http://localhost:8080
```

### 生产环境

`.env.production`
```
VITE_API_BASE_URL=https://your-production-domain.com
```

## 页面说明

### 使用Code页面

1. **访问码输入**：输入有效的访问码
2. **文章链接输入**：输入文章的URL
3. **使用Code**：点击按钮开始下载
4. **结果展示**：
   - 打开HTML：在新标签页中预览下载的HTML
   - 下载压缩包：下载包含HTML和资源的ZIP文件

## 响应式设计

- **手机端**（< 768px）：
  - 全屏宽度布局
  - 简化的间距
  - 优化的触摸体验
  - 防止页面缩放

- **平板/桌面端**（>= 768px）：
  - 居中卡片布局
  - 完整的视觉效果
  - 悬停和动画效果

## 微信小程序兼容性

本项目设计时考虑了微信小程序迁移的兼容性：

1. **标准Vue组件**：使用Vue 3 Composition API
2. **原生Fetch API**：可直接替换为wx.request
3. **简单的样式**：基于CSS，可转换为WXSS
4. **表单结构清晰**：便于重构为小程序表单
5. **API调用标准化**：易于替换为小程序网络请求

## 迁移到微信小程序建议

1. **网络请求**：将fetch替换为wx.request
2. **样式转换**：将CSS转换为WXSS
3. **组件重构**：将Vue组件转换为小程序页面
4. **文件下载**：使用wx.downloadFile和wx.openDocument
5. **预览功能**：使用web-view组件预览HTML

## API接口

### 使用Code
```
POST /api/codes/use
Content-Type: application/json

{
  "code": "访问码",
  "targetUrl": "文章URL",
  "userId": null
}

Response: 文件路径
```

### 打开HTML
```
GET /api/html-resource/view-by-path/{filePath}
```

### 下载压缩包
```
GET /api/html-resource/download/{filePath}
```

## 部署建议

### Nginx配置

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    root /path/to/dist;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 静态托管

可以将`dist`目录部署到任何静态托管服务：
- Vercel
- Netlify
- GitHub Pages
- 阿里云OSS
- 腾讯云COS

## 浏览器支持

- Chrome (推荐)
- Firefox
- Safari
- Edge
- 移动端浏览器

## 注意事项

1. **后端API**：确保后端服务正常运行并配置了CORS
2. **HTTPS**：生产环境建议使用HTTPS
3. **域名配置**：正确配置API基础URL
4. **移动端优化**：已针对移动端进行优化，但建议在真实设备上测试

## 开发规范

- 使用TypeScript进行类型检查
- 遵循Vue 3 Composition API最佳实践
- 保持代码简洁，避免过度设计
- 优先考虑移动端体验
- 便于后续迁移到小程序

## 常见问题

### Q: 页面加载慢？
A: 检查网络连接和API服务器响应时间

### Q: 点击按钮没有反应？
A: 检查表单验证，确保访问码和URL都填写正确

### Q: 下载失败？
A: 检查浏览器下载权限和API服务器状态

### Q: 手机端显示异常？
A: 确保使用现代浏览器，清除缓存后重试

## License

MIT
