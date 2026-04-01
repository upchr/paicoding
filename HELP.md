# 技术派社区 - 快速上手指南

## 目录

- [项目简介](#项目简介)
- [环境准备](#环境准备)
- [快速启动](#快速启动)
  - [后端启动](#后端启动)
  - [前端启动](#前端启动)
- [项目使用](#项目使用)
  - [访问系统](#访问系统)
  - [主要功能](#主要功能)
  - [API 文档](#api-文档)
- [学习路径](#学习路径)
  - [初学者](#初学者)
  - [进阶学习](#进阶学习)
  - [深度开发](#深度开发)
- [常见问题](#常见问题)
- [开发资源](#开发资源)

---

## 项目简介

技术派（paicoding）是一个基于 Spring Boot 3、Vue 3、MySQL、Redis、ElasticSearch 等主流技术栈实现的现代化社区系统，支持文章发布、搜索、评论、用户互动等完整功能，非常适合二次开发和实战学习。

**技术特点：**
- 前后端分离架构
- 代码完全开源，无二次封装
- 支持一键源码部署
- 完整的业务流程实现
- 现代化的 UI 设计

---

## 环境准备

### 必需软件

| 软件 | 版本要求 | 下载地址 |
|------|---------|---------|
| JDK | 17+ | [Oracle JDK](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) |
| Maven | 3.5+ | [Maven](https://maven.apache.org/) |
| Node.js | 18+ | [Node.js](https://nodejs.org/) |
| MySQL | 8.0+ | [MySQL](https://www.mysql.com/downloads/) |
| Redis | 6.0+ | [Redis](https://redis.io/download/) |
| Git | 任意版本 | [Git](https://git-scm.com/) |

### 可选软件

- **ElasticSearch 8.0+**：用于全文搜索功能
- **RabbitMQ 3.12+**：用于消息队列功能
- **MongoDB**：用于某些数据存储
- **Docker**：用于容器化部署

### 开发工具推荐

- **后端开发**：IntelliJ IDEA
- **前端开发**：VS Code 或 WebStorm
- **数据库管理**：Navicat 或 DBeaver
- **API 测试**：Postman 或 Apifox

---

## 快速启动

### 后端启动

#### 1. 克隆项目

```bash
git clone https://github.com/itwanger/paicoding.git
cd paicoding
```

#### 2. 配置数据库

**自动创建数据库（推荐）：**

项目启动时会自动创建数据库和表结构，无需手动执行 SQL。

默认数据库名：`pai_coding`

如需修改数据库名，编辑 `paicoding-web/src/main/resources/application.yml`：

```yaml
database:
  name: your_database_name
```

**手动创建数据库（可选）：**

```sql
CREATE DATABASE pai_coding CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 3. 配置数据库连接

编辑 `paicoding-web/src/main/resources/resources-env/dev/application-dal.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/pai_coding?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password
```

#### 4. 配置 Redis（可选但推荐）

编辑 `paicoding-web/src/main/resources/resources-env/dev/application-dal.yml`：

```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: # 如果有密码
      database: 0
```

#### 5. 启动项目

**方式一：使用 IDEA**

1. 打开 IDEA，导入项目
2. 等待 Maven 依赖下载完成
3. 找到 `paicoding-web/src/main/java/com/github/paicoding/forum/web/QuickForumApplication.java`
4. 右键运行 `QuickForumApplication`

**方式二：使用命令行**

```bash
# 编译项目
mvn clean install -DskipTests=true

# 启动项目
cd paicoding-web
mvn spring-boot:run
```

#### 6. 验证启动成功

看到以下日志表示启动成功：

```
启动成功，点击进入首页: http://127.0.0.1:8081
```

访问 `http://localhost:8081` 查看首页。

### 前端启动

#### 1. 进入前端目录

```bash
cd pai-coding-front
```

#### 2. 安装依赖

```bash
npm install
```

如果安装缓慢，可以使用国内镜像：

```bash
npm install --registry=https://registry.npmmirror.com
```

#### 3. 配置后端地址

编辑 `pai-coding-front/src/http/URL.ts`：

```typescript
// 后端接口地址
export const BASE_URL = "http://localhost:8081"
export const WS_URL = "ws://localhost:8081"
```

#### 4. 启动开发服务器

```bash
npm run dev
```

#### 5. 访问前端

浏览器访问：`http://localhost:5173`

#### 6. 构建生产版本（可选）

```bash
npm run build
```

构建产物在 `dist` 目录，可部署到 Nginx 等服务器。

---

## 项目使用

### 访问系统

启动成功后，可以通过以下地址访问：

| 服务 | 地址 | 说明 |
|------|------|------|
| 前台社区 | http://localhost:5173 | Vue3 前端界面 |
| 后端接口 | http://localhost:8081 | Spring Boot 后端 |
| API 文档 | http://localhost:8081/swagger-ui.html | Knife4j 接口文档 |
| Knife4j | http://localhost:8081/doc.html | Knife4j 增强文档 |

### 主要功能

#### 1. 用户功能

- **用户注册/登录**：支持用户名密码登录、微信模拟登录
- **个人中心**：查看和管理个人信息
- **文章管理**：发布、编辑、删除文章
- **收藏系统**：收藏喜欢的文章
- **关注系统**：关注其他用户
- **浏览历史**：查看浏览记录

#### 2. 文章功能

- **文章发布**：支持 Markdown 编辑
- **文章分类**：按分类浏览文章
- **文章标签**：按标签浏览文章
- **文章搜索**：全文搜索功能
- **文章点赞/收藏**：互动功能
- **文章评论**：支持评论和回复

#### 3. 专栏功能

- **专栏创建**：创建个人专栏
- **专栏文章**：组织系列文章
- **专栏阅读**：连续阅读体验

#### 4. 通知功能

- **消息通知**：评论、点赞、关注等通知
- **系统消息**：系统公告

#### 5. 工具功能

- **Excel 处理**：在线 Excel 工具
- **AI 聊天**：集成 AI 对话功能

### API 文档

#### 访问 API 文档

**Knife4j 访问地址：**

- UI 界面：`http://localhost:8081/doc.html`
- Swagger UI：`http://localhost:8081/swagger-ui.html`

**认证信息：**

- 用户名：`root`
- 密码：`123456`

#### API 分组

- **前台接口分组**：包含前台社区的所有接口
- **后台接口分组**：包含后台管理的所有接口

#### 测试接口

1. 打开 Knife4j 文档页面
2. 点击接口展开详情
3. 点击"调试"按钮
4. 填写参数
5. 点击"发送"进行测试

---

## 学习路径

### 初学者

#### 第一步：熟悉项目结构

```
paicoding/
├── pai-coding-front/    # Vue3 前端
├── paicoding-api/       # API 定义层
├── paicoding-core/      # 核心工具层
├── paicoding-service/   # 业务服务层
└── paicoding-web/       # Web 接口层
```

#### 第二步：运行项目

按照上面的"快速启动"步骤，成功启动前后端项目。

#### 第三步：体验功能

1. 注册/登录账号
2. 发布第一篇文章
3. 浏览其他文章
4. 评论和点赞
5. 查看个人中心

#### 第四步：阅读代码

**后端学习顺序：**

1. `QuickForumApplication.java` - 启动类
2. `controller/` - 控制器层
3. `service/` - 业务逻辑层
4. `api/` - 数据模型层

**前端学习顺序：**

1. `main.ts` - 入口文件
2. `router/index.ts` - 路由配置
3. `views/` - 页面组件
4. `components/` - 公共组件
5. `http/BackendRequests.ts` - HTTP 请求

#### 第五步：阅读文档

- [README.md](README.md) - 项目介绍
- [docs/约定.md](docs/约定.md) - 开发规范
- [docs/前端工程结构说明.md](docs/前端工程结构说明.md) - 前端结构

### 进阶学习

#### 第一步：理解架构设计

**分层架构：**

```
Controller（接口层）
    ↓
Service（业务层）
    ↓
DAO（数据访问层）
    ↓
Database（数据库）
```

**前后端分离：**

- 前端：Vue3 + Vite + Element Plus
- 后端：Spring Boot + MyBatis-Plus
- 通信：RESTful API + Axios

#### 第二步：学习核心技术

**后端技术：**

- Spring Boot 自动配置
- MyBatis-Plus CRUD 操作
- Redis 缓存应用
- Elasticsearch 全文搜索
- RabbitMQ 消息队列
- JWT 身份认证

**前端技术：**

- Vue3 Composition API
- Pinia 状态管理
- Vue Router 路由管理
- Axios HTTP 请求
- Element Plus 组件库

#### 第三步：研究核心功能

**推荐研究顺序：**

1. **用户认证**：登录、注册、JWT
   - 后端：`controller/rest/UserRestController.java`
   - 前端：`views/HomeView.vue` 中的登录逻辑

2. **文章发布**：文章创建、编辑、删除
   - 后端：`service/article/` 相关服务
   - 前端：`views/ArticleEditView.vue`

3. **文章展示**：文章列表、详情、搜索
   - 后端：`controller/rest/ArticleRestController.java`
   - 前端：`views/HomeView.vue`、`views/ArticleDetailView.vue`

4. **评论系统**：评论、回复、点赞
   - 后端：`service/comment/` 相关服务
   - 前端：`components/comment/` 相关组件

5. **用户关注**：关注、粉丝、用户信息
   - 后端：`service/user/` 相关服务
   - 前端：`views/UserHomeView.vue`

#### 第四步：修改和调试

**实践建议：**

1. 修改页面样式，观察变化
2. 添加一个简单的接口
3. 创建一个新的页面
4. 添加一个新的业务功能
5. 使用 IDEA 的断点调试功能

#### 第五步：阅读源码

**重点关注：**

- `GlobalExceptionHandler` - 全局异常处理
- `GlobalViewInterceptor` - 全局拦截器
- `SpringUtil` - Spring 工具类
- `JwtUtil` - JWT 工具类
- `BackendRequests.ts` - 前端请求封装

### 深度开发

#### 第一步：二次开发

**添加新功能的步骤：**

1. **设计数据库表**（如需要）
   - 在 `liquibase` 中添加 changelog

2. **创建数据模型**
   - 在 `paicoding-api` 中创建 DTO/VO

3. **实现业务逻辑**
   - 在 `paicoding-service` 中创建 Service

4. **创建接口**
   - 在 `paicoding-web` 中创建 Controller

5. **前端页面开发**
   - 在 `pai-coding-front` 中创建页面和组件

6. **测试和调试**

#### 第二步：性能优化

**优化方向：**

- 数据库查询优化
- Redis 缓存应用
- 接口响应优化
- 前端页面加载优化
- 图片压缩和 CDN

#### 第三步：部署上线

**部署步骤：**

1. 配置生产环境参数
2. 构建前端项目
3. 打包后端项目
4. 配置 Nginx
5. 部署到服务器
6. 配置域名和 HTTPS

详细部署教程请参考：[docs/服务器启动教程.md](docs/服务器启动教程.md)

#### 第四步：贡献代码

**参与项目贡献：**

1. Fork 项目仓库
2. 创建功能分支
3. 提交代码
4. 发起 Pull Request

---

## 常见问题

### 启动问题

**Q: 启动后端时提示端口被占用？**

A: 项目会自动检测并使用 8000-10000 范围内的可用端口，或者手动修改 `application.yml` 中的端口配置。

**Q: 数据库连接失败？**

A: 检查以下几点：
- MySQL 服务是否启动
- 数据库连接配置是否正确
- 用户名和密码是否正确
- 防火墙是否阻止连接

**Q: Redis 连接失败？**

A: 检查 Redis 服务是否启动，连接配置是否正确。如果不需要缓存功能，可以暂时注释掉 Redis 配置。

**Q: 前端启动失败？**

A: 尝试以下步骤：
1. 删除 `node_modules` 目录
2. 删除 `package-lock.json`
3. 重新执行 `npm install`
4. 如果网络慢，使用国内镜像

### 使用问题

**Q: 如何添加管理员账号？**

A: 查看 `liquibase` 初始化脚本，会自动创建测试数据，包括管理员账号。

**Q: 如何修改网站配置？**

A: 编辑 `paicoding-web/src/main/resources/application-config.yml` 文件。

**Q: 如何启用 Elasticsearch？**

A: 启动 Elasticsearch 服务，然后在配置文件中添加 Elasticsearch 配置。

**Q: 如何自定义主题？**

A: 前端使用 Tailwind CSS，可以修改 `tailwind.config.js` 自定义主题。

### 开发问题

**Q: 如何调试后端代码？**

A: 在 IDEA 中设置断点，使用 Debug 模式启动项目。

**Q: 如何调试前端代码？**

A: 使用浏览器开发者工具，或者在 VS Code 中安装 Vue DevTools 扩展。

**Q: 如何添加新的依赖？**

A:
- 后端：在对应模块的 `pom.xml` 中添加依赖
- 前端：执行 `npm install 包名`

**Q: 如何切换环境？**

A:
- 后端：使用 Maven profile，如 `mvn clean install -Pprod`
- 前端：修改 `.env` 文件或使用环境变量

---

## 开发资源

### 项目文档

- [README.md](README.md) - 项目介绍
- [HELP.md](HELP.md) - 本文档，快速上手指南
- [docs/安装环境.md](docs/安装环境.md) - 环境搭建教程
- [docs/本地开发环境配置教程.md](docs/本地开发环境配置教程.md) - 本地开发教程
- [docs/服务器启动教程.md](docs/服务器启动教程.md) - 服务器部署教程
- [docs/约定.md](docs/约定.md) - 开发规范
- [docs/前端工程结构说明.md](docs/前端工程结构说明.md) - 前端结构说明
- [docs/配套教程.md](docs/配套教程.md) - 配套学习教程

### 官方资源

- **GitHub 仓库**：https://github.com/itwanger/paicoding
- **在线演示**：http://www.xuyifei.site
- **管理端源码**：https://github.com/itwanger/paicoding-admin

### 技术文档

- **Spring Boot 官方文档**：https://spring.io/projects/spring-boot
- **Vue3 官方文档**：https://cn.vuejs.org/
- **MyBatis-Plus 文档**：https://baomidou.com/
- **Element Plus 文档**：https://element-plus.org/zh-CN/
- **Vite 文档**：https://cn.vitejs.dev/

### 社区资源

- **Spring 中文社区**：https://springcloud.cn/
- **Vue 中文社区**：https://vuejs.cn/
- **掘金技术社区**：https://juejin.cn/
- **SegmentFault**：https://segmentfault.com/

### 视频教程

- B站搜索"技术派"相关教程
- YouTube 搜索"paicoding tutorial"

---

## 下一步

现在你已经了解了如何启动和使用技术派社区系统，接下来可以：

1. **深入源码**：选择一个感兴趣的功能模块，深入阅读和理解代码
2. **动手实践**：尝试添加一个新功能或修改现有功能
3. **性能优化**：学习如何优化系统性能
4. **部署上线**：将项目部署到云服务器
5. **分享交流**：在技术社区分享你的学习心得

祝你学习愉快！如有问题，欢迎在 GitHub 提 Issue 或参与讨论。