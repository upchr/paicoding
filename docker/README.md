# Docker 部署配置

## 目录结构

```
docker/
├── Dockerfile              # 后端 Docker 镜像定义
├── .dockerignore          # Docker 构建忽略文件
├── .env.example           # 环境变量配置示例
├── docker-compose.yml     # Docker Compose 配置
├── nginx.conf             # Nginx 配置文件
├── config/                # 外部配置文件目录
│   ├── application.yml
│   ├── application-dal.yml
│   ├── application-web.yml
│   ├── application-config.yml
│   ├── application-image.yml
│   ├── application-email.yml
│   ├── application-rabbitmq.yml
│   └── application-ai.yml
├── build.sh               # Linux/Mac 构建脚本
├── build.bat              # Windows 构建脚本
└── README.md              # 本文档
```

## 快速开始

### 1. 配置环境变量

```bash
# 复制环境变量示例文件
cp docker/.env.example docker/.env

# 编辑 .env 文件，修改数据库密码等敏感信息
```

### 2. 构建后端 Docker 镜像

**Windows:**
```bash
docker\build.bat prod
```

**Linux/Mac:**
```bash
chmod +x docker/build.sh
docker/build.sh prod
```

### 3. 使用 Docker Compose 启动

```bash
cd docker
docker-compose up -d
```

### 4. 查看日志

```bash
docker-compose logs -f
```

### 5. 停止服务

```bash
docker-compose down
```

## 配置说明

### Dockerfile
- 基础镜像: `eclipse-temurin:17-jdk-alpine`
- 工作目录: `/app`
- 暴露端口: `8081`
- JVM 参数: `-Xms512m -Xmx1024m -XX:+UseG1GC`
- 配置文件: 外挂到 `/app/config`
- 启动参数: `-Dspring.config.location=classpath:/,file:/app/config/`

### 配置文件外挂
项目采用配置文件外挂的方式，jar 包内不包含任何配置文件，防止敏感信息泄露：

- **配置位置**: `docker/config/` 目录
- **容器内路径**: `/app/config`
- **优先级**: 外部配置 > 内部配置
- **优势**:
  - 敏感信息不打包进 jar
  - 配置修改无需重新打包
  - 不同环境使用不同配置

### 环境变量配置
支持通过环境变量覆盖配置：

- `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD` - 数据库配置
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD` - Redis 配置
- `JWT_SECRET` - JWT 签名密钥
- `KNIFE4J_PASSWORD` - Knife4j 文档密码
- `SECURITY_SALT` - 安全盐

### docker-compose.yml
- 构建上下文: `..` (项目根目录)
- Dockerfile: `docker/Dockerfile`
- 端口映射: `8081:8081`
- 日志挂载: `../logs:/app/logs`
- 数据挂载: `../data:/app/data`
- 配置挂载: `./config:/app/config:ro`
- 健康检查: `/actuator/health`

### nginx.conf
- 前端静态文件: `/` → `/usr/share/nginx/html`
- 后端 API: `/api/` → `http://paicoding-backend:8081/api/`
- Swagger UI: `/swagger-ui/` → 后端服务
- Knife4j: `/doc.html` → 后端服务
- 文件上传: `/upload/` → 后端服务
- WebSocket: `/ws/` → 后端服务

## 配置文件结构

### application.yml
主配置文件，包含：
- 服务器配置（端口、压缩等）
- Spring Boot 基础配置
- 业务配置（JWT、敏感词等）
- Knife4j 文档配置

### application-dal.yml
数据访问层配置：
- MySQL 数据库配置
- Redis 配置
- Elasticsearch 配置

### application-web.yml
Web 层配置：
- MVC 配置
- 文件上传配置

### application-config.yml
业务配置：
- 管理员配置
- 其他业务参数

### application-image.yml
图片处理配置：
- 上传路径
- 文件大小限制

### application-email.yml
邮件配置：
- SMTP 服务器
- 发件人信息

### application-rabbitmq.yml
消息队列配置：
- RabbitMQ 连接信息
- 虚拟主机配置

### application-ai.yml
AI 功能配置：
- AI 服务开关
- API 密钥和地址

## 安全注意事项

1. **不要将 .env 文件提交到版本控制**
2. **生产环境务必修改默认密码和密钥**
3. **配置文件使用环境变量引用敏感信息**
4. **jar 包不包含任何配置文件**
5. **配置文件挂载为只读（ro）**

## 注意事项

1. **构建上下文**: Docker 构建时使用项目根目录作为上下文，Dockerfile 位于 `docker/` 子目录
2. **环境切换**: 通过 `SPRING_PROFILES_ACTIVE` 环境变量切换，默认为 prod
3. **配置优先级**: 环境变量 > 外部配置文件 > 内部配置
4. **日志目录**: 容器内的 `/app/logs` 映射到宿主机的 `logs/` 目录
5. **前端部署**: 需要单独构建前端并挂载到 nginx 的 `/usr/share/nginx/html`
6. **数据库连接**: 确保 Docker 网络中可以访问数据库，或使用宿主机网络

## Nginx 部署

如果使用独立的 Nginx 服务器，复制配置文件：

```bash
cp docker/nginx.conf /etc/nginx/nginx.conf
nginx -t
nginx -s reload
```

## 常用命令

```bash
# 构建镜像
docker build -f docker/Dockerfile -t paicoding-backend:latest .

# 运行容器
docker run -d -p 8081:8081 --name paicoding-backend paicoding-backend:latest

# 使用环境变量运行
docker run -d -p 8081:8081 \
  -e DB_PASSWORD=your_password \
  -e JWT_SECRET=your_secret \
  --name paicoding-backend \
  paicoding-backend:latest

# 查看日志
docker logs -f paicoding-backend

# 进入容器
docker exec -it paicoding-backend sh

# 停止容器
docker stop paicoding-backend

# 删除容器
docker rm paicoding-backend

# 删除镜像
docker rmi paicoding-backend:latest

# 查看配置文件
docker exec paicoding-backend cat /app/config/application.yml
```

## 故障排查

### 配置文件未生效
检查 Spring Boot 启动参数是否包含：
```
-Dspring.config.location=classpath:/,file:/app/config/
```

### 环境变量未生效
确保环境变量在 docker-compose.yml 中正确配置，或者在运行时通过 `-e` 参数传递。

### 连接数据库失败
检查网络配置，确保容器可以访问数据库服务器。可以使用 `docker network inspect` 查看网络配置。