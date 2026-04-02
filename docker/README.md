# Docker 部署文档

技术派社区系统 Docker 部署指南

## 目录

- [前置要求](#前置要求)
- [快速开始](#快速开始)
- [环境变量配置](#环境变量配置)
- [详细配置说明](#详细配置说明)
- [维护与监控](#维护与监控)
- [常见问题](#常见问题)

## 前置要求

### 必需软件

- Docker 20.10+
- Docker Compose 2.0+

### 可选依赖

根据实际使用需求，你可能需要部署以下服务：

- MySQL 8.0+（数据库）
- Redis 6.0+（缓存）
- Elasticsearch 7.x+（全文搜索）
- RabbitMQ 3.x+（消息队列）

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/upchr/paicoding.git
cd paicoding
```

### 2. 配置环境变量

```bash
cd docker
cp .env.example .env
```

编辑 `.env` 文件，修改必要的配置项（至少需要修改数据库和 Redis 配置）：

```bash
# 使用你喜欢的编辑器打开 .env 文件
vim .env  # 或使用 notepad++、VS Code 等
```

### 3. 启动服务

```bash
# 构建并启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 查看服务状态
docker-compose ps
```

### 4. 访问应用

- 应用访问地址：`http://localhost:8081`
- API 文档：`http://localhost:8081/swagger-ui.html`
  - 用户名：`root`
  - 密码：在 `.env` 文件中的 `KNIFE4J_PASSWORD` 配置项

## 环境变量配置

### 核心配置

| 配置项 | 说明 | 默认值 | 必填 |
|--------|------|--------|------|
| `DB_HOST` | 数据库主机地址 | localhost | 是 |
| `DB_PORT` | 数据库端口 | 3306 | 是 |
| `DB_NAME` | 数据库名称 | pai_coding_2026 | 是 |
| `DB_USERNAME` | 数据库用户名 | root | 是 |
| `DB_PASSWORD` | 数据库密码 | 123456 | 是 |
| `REDIS_HOST` | Redis 主机地址 | localhost | 是 |
| `REDIS_PORT` | Redis 端口 | 6379 | 是 |
| `REDIS_PASSWORD` | Redis 密码 | - | 否 |
| `JWT_SECRET` | JWT 签名密钥 | hello_world | **强烈建议修改** |
| `SECURITY_SALT` | 安全盐值 | tech_π | **强烈建议修改** |

### 可选配置

#### Elasticsearch 配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `ES_URIS` | Elasticsearch 地址 | http://localhost:9200 |
| `ES_USERNAME` | Elasticsearch 用户名 | elastic |
| `ES_PASSWORD` | Elasticsearch 密码 | elastic |

#### RabbitMQ 配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `RABBITMQ_HOST` | RabbitMQ 主机地址 | localhost |
| `RABBITMQ_PORT` | RabbitMQ 端口 | 5672 |
| `RABBITMQ_USERNAME` | RabbitMQ 用户名 | guest |
| `RABBITMQ_PASSWORD` | RabbitMQ 密码 | guest |
| `RABBITMQ_VHOST` | RabbitMQ 虚拟主机 | / |
| `RABBITMQ_ENABLED` | 是否启用 RabbitMQ | false |

#### 邮件配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `MAIL_HOST` | SMTP 服务器地址 | smtp.qq.com |
| `MAIL_PORT` | SMTP 端口 | 587 |
| `MAIL_USERNAME` | 邮箱用户名 | - |
| `MAIL_PASSWORD` | 邮箱密码/授权码 | - |
| `MAIL_FROM` | 发件人邮箱 | - |

#### AI 配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `AI_ENABLED` | 是否启用 AI 功能 | false |
| `CHATGPT_3_5_KEY` | ChatGPT 3.5 API Key | - |
| `CHATGPT_4_KEY` | ChatGPT 4 API Key | - |
| `CHATGPT_PROXY` | 是否使用代理访问 ChatGPT | false |
| `CHATGPT_API_HOST` | ChatGPT API 地址 | https://api.openai.com/ |
| `XUNFEI_APP_ID` | 讯飞 AI App ID | - |
| `XUNFEI_API_KEY` | 讯飞 AI API Key | - |
| `XUNFEI_API_SECRET` | 讯飞 AI API Secret | - |

#### Knife4j 配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `KNIFE4J_PASSWORD` | API 文档访问密码 | 123456 |
| `KNIFE4J_PRODUCTION` | 生产环境是否禁用 API 文档 | false |
| `KNIFE4J_BASIC_ENABLE` | 是否启用 API 文档认证 | false |

## 详细配置说明

### 数据库配置

项目使用 MySQL 作为主数据库，支持单数据源和主从数据源配置。

**重要提示：**
- 数据库会在首次启动时自动创建（通过 Liquibase）
- 确保 MySQL 用户有创建数据库和表的权限
- 推荐使用 MySQL 8.0+ 版本

### Redis 配置

Redis 用于缓存和会话存储。

**重要提示：**
- 如果 Redis 设置了密码，必须在 `REDIS_PASSWORD` 中配置
- 推荐使用 Redis 6.0+ 版本

### JWT 和安全配置

**生产环境安全建议：**

1. **修改 JWT_SECRET**：使用强随机字符串（至少 32 位）
   ```bash
   # 生成随机密钥
   openssl rand -base64 32
   ```

2. **修改 SECURITY_SALT**：使用唯一的盐值
   ```bash
   # 生成随机盐值
   openssl rand -base64 16
   ```

3. **修改 Knife4j 密码**：设置强密码

4. **在生产环境禁用 API 文档**：
   ```bash
   KNIFE4J_PRODUCTION=true
   ```

### 邮件配置

邮件功能用于发送通知和验证邮件。

**常见邮箱配置：**

**QQ 邮箱：**
```bash
MAIL_HOST=smtp.qq.com
MAIL_PORT=587
MAIL_USERNAME=your_email@qq.com
MAIL_PASSWORD=your_authorization_code
```

**163 邮箱：**
```bash
MAIL_HOST=smtp.163.com
MAIL_PORT=465
MAIL_USERNAME=your_email@163.com
MAIL_PASSWORD=your_authorization_code
```

### AI 配置

AI 功能包括 ChatGPT 和讯飞 AI。

**ChatGPT 配置：**
1. 获取 OpenAI API Key
2. 如果需要代理访问，设置 `CHATGPT_PROXY=true`
3. 配置代理服务器信息（在 application-ai.yml 中）

**讯飞 AI 配置：**
1. 在讯飞开放平台创建应用
2. 获取 AppID、API Key、API Secret
3. 填入对应的环境变量

## 维护与监控

### 查看日志

```bash
# 查看所有日志
docker-compose logs -f

# 查看最近 100 行日志
docker-compose logs --tail=100 -f

# 查看特定时间的日志
docker-compose logs --since=2024-01-01T00:00:00
```

### 重启服务

```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart paicoding-backend
```

### 更新应用

```bash
# 拉取最新代码
git pull

# 重新构建并启动
docker-compose up -d --build

# 清理旧镜像
docker image prune -f
```

### 备份数据

```bash
# 备份日志
tar -czf logs-backup-$(date +%Y%m%d).tar.gz logs/

# 备份上传的文件
tar -czf data-backup-$(date +%Y%m%d).tar.gz data/
```

### 健康检查

服务包含内置的健康检查，可以通过以下方式查看：

```bash
# 检查容器健康状态
docker-compose ps

# 手动执行健康检查
curl http://localhost:8081/actuator/health
```

## 常见问题

### 1. 容器启动失败

**问题：** 容器无法启动或立即退出

**解决方案：**
```bash
# 查看详细日志
docker-compose logs paicoding-backend

# 检查环境变量配置
docker-compose config

# 验证端口是否被占用
netstat -tuln | grep 8081
```

### 2. 数据库连接失败

**问题：** 无法连接到数据库

**解决方案：**
- 检查数据库服务是否运行
- 验证 `.env` 中的数据库配置
- 确保数据库用户有足够权限
- 检查防火墙和网络连接

### 3. Redis 连接失败

**问题：** 无法连接到 Redis

**解决方案：**
- 确认 Redis 服务是否运行
- 检查 Redis 密码配置
- 验证 Redis 端口是否可访问

### 4. 权限问题

**问题：** 文件上传或日志写入失败

**解决方案：**
```bash
# 确保日志目录有写权限
chmod -R 755 logs/

# 确保数据目录有写权限
chmod -R 755 data/
```

### 5. 内存不足

**问题：** 容器因内存不足被 OOM Killer 终止

**解决方案：**
在 `docker-compose.yml` 中添加内存限制：
```yaml
services:
  paicoding-backend:
    mem_limit: 2g
    memswap_limit: 2g
```

### 6. 时区问题

**问题：** 日志时间不正确

**解决方案：**
确保 `TZ` 环境变量设置为正确的时区（默认：`Asia/Shanghai`）

## 安全建议

1. **不要提交 .env 文件**：`.env` 已在 `.gitignore` 中，确保不要提交到版本控制
2. **使用强密码**：所有密码相关配置都应使用强密码
3. **定期更新**：及时更新 Docker 镜像和依赖
4. **限制访问**：在生产环境中使用防火墙限制访问
5. **禁用不必要的功能**：在生产环境禁用 API 文档等开发功能
6. **定期备份**：定期备份数据库和上传的文件

## 生产部署建议

### 1. 使用反向代理

建议使用 Nginx 作为反向代理：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. 配置 HTTPS

使用 Let's Encrypt 免费证书：

```bash
# 安装 certbot
apt-get install certbot

# 获取证书
certbot certonly --standalone -d your-domain.com

# 配置 Nginx SSL
```

### 3. 监控和告警

- 使用 Prometheus + Grafana 监控应用性能
- 配置日志收集（ELK Stack 或 Loki）
- 设置关键指标的告警

### 4. 高可用部署

- 使用负载均衡器（如 Nginx、HAProxy）
- 部署多个实例
- 使用健康检查和自动重启

## 支持与反馈

- 项目地址：https://github.com/upchr/paicoding
- 问题反馈：https://github.com/upchr/paicoding/issues
- 文档：docs/ 目录

## 许可证

Apache License 2.0

---

**最后更新：** 2026-04-02