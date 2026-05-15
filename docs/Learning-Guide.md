# 技术派项目 — 学习指南

> 从零开始学习技术派项目，循序渐进掌握 Spring Boot 3 + Vue 3 全栈开发

---

## 一、学习路线图

```
阶段1：环境搭建与项目运行（1-2天）
    │
阶段2：理解项目架构与模块划分（2-3天）
    │
阶段3：核心功能源码精读（5-7天）
    │
阶段4：扩展功能与高级特性（3-5天）
    │
阶段5：实战练习与改进（持续）
```

---

## 二、阶段1：环境搭建与项目运行

### 2.1 前置知识要求

| 知识领域 | 要求程度 | 推荐资源 |
|---------|---------|---------|
| Java 基础 | 熟练 | 《Java 核心技术》 |
| Spring Boot | 了解基本用法 | Spring Boot 官方文档 |
| MySQL | 基本 SQL 操作 | MySQL 教程 |
| Redis | 了解数据结构 | Redis 官方文档 |
| Vue 3 | 了解组合式 API | Vue 3 官方文档 |
| TypeScript | 基本类型系统 | TypeScript 官方手册 |

### 2.2 环境准备

**后端环境**：

```bash
# 1. 安装 JDK 17
java -version  # 确认 java 17

# 2. 安装 Maven 3.8+
mvn -version

# 3. 安装 MySQL 8.x
mysql --version

# 4. 安装 Redis
redis-server --version

# 5. 克隆项目
git clone <repo-url>
cd paicoding
```

**前端环境**：

```bash
# 1. 安装 Node.js 20+
node -version

# 2. 进入前端目录
cd pai-coding-front
npm install
```

### 2.3 配置与启动

**后端配置**：

修改 `paicoding-web/src/main/resources-env/dev/application-dal.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/pai_coding_2026?useUnicode=true&characterEncoding=UTF-8
    username: root
    password: 你的密码
```

启动后端：
- 在 IDEA 中运行 `QuickForumApplication` 主类
- 或命令行：`mvn spring-boot:run -pl paicoding-web`
- 默认端口：8081
- 数据库会自动创建（Liquibase）

启动前端：

```bash
cd pai-coding-front
npm run dev
```

访问 http://localhost:5173 即可看到页面。

### 2.4 验证环境

| 检查项 | 验证方式 |
|--------|---------|
| 后端启动 | 访问 http://localhost:8081/api/global/info |
| 数据库初始化 | 检查 MySQL 中 pai_coding_2026 数据库是否创建 |
| 前端启动 | 访问 http://localhost:5173 |
| API 代理 | 前端页面能正常加载文章列表 |
| Swagger文档 | 访问 http://localhost:8081/doc.html |

---

## 三、阶段2：理解项目架构与模块划分

### 3.1 整体架构理解

**学习目标**：理解项目的分层架构和模块依赖关系。

**学习步骤**：

1. **阅读根 pom.xml**：理解 Maven 多模块结构和依赖管理
2. **阅读各模块 pom.xml**：理解模块间的依赖关系
3. **画出依赖关系图**：api ← core ← service ← web
4. **理解每个模块的职责**：

| 模块 | 一句话描述 | 类比 |
|------|-----------|------|
| paicoding-api | 定义"语言"（枚举、实体、异常） | 字典 |
| paicoding-core | 提供"工具"（缓存、数据源、权限） | 工具箱 |
| paicoding-service | 实现"业务"（文章、用户、评论） | 工厂 |
| paicoding-web | 暴露"接口"（Controller、拦截器） | 门店 |

**练习**：
- 尝试在 paicoding-api 中新增一个枚举类
- 尝试在 paicoding-core 中新增一个工具类
- 理解为什么 web 不能被其他模块依赖

### 3.2 请求处理链路

**学习目标**：理解一个 HTTP 请求从进入到响应的完整链路。

**关键代码阅读顺序**：

```
1. ReqRecordFilter.doFilter()
   ↓ 初始化 ReqInfoContext、识别登录用户、CORS、traceId
2. GlobalViewInterceptor.preHandle()
   ↓ 权限校验(@Permission)、活跃度更新
3. Controller 方法
   ↓ 业务处理
4. Service 层方法
   ↓ 业务逻辑 + 数据库操作
5. GlobalExceptionHandler
   ↓ 异常兜底
```

**练习**：
- 在浏览器开发者工具中跟踪一个 API 请求
- 在 ReqRecordFilter 中打断点，观察请求上下文的初始化
- 在 GlobalViewInterceptor 中打断点，观察权限校验流程

### 3.3 配置体系

**学习目标**：理解多环境配置和配置加载机制。

**关键文件**：
- `application.yml`：主配置入口
- `resources-env/dev/`：开发环境配置
- `resources-env/prod/`：生产环境配置

**练习**：
- 修改 dev 环境的端口号，验证是否生效
- 理解 Maven Profile 如何切换环境
- 找出所有通过环境变量注入的配置项

---

## 四、阶段3：核心功能源码精读

### 4.1 文章系统（必读）

**学习目标**：理解文章的完整生命周期。

**源码阅读路线**：

```
1. 数据库层
   ├── article 表结构（article + article_detail 拆分设计）
   ├── ArticleMapper.xml（SQL 映射）
   └── ArticleDao.java（数据访问对象）

2. 服务层
   ├── ArticleReadService.java（文章读取接口）
   ├── ArticleWriteService.java（文章写入接口）
   ├── ArticleCacheManager.java（缓存管理）
   └── ArticleRecommendService.java（推荐逻辑）

3. 控制器层
   ├── ArticleRestController.java（文章详情API）
   └── ArticleListRestController.java（文章列表API）

4. 前端
   ├── ArticleDetailView.vue（文章详情页）
   ├── ArticleEditView.vue（文章编辑页，md-editor-v3）
   └── ArticleCard.vue（文章卡片组件）
```

**重点理解**：
- article 和 article_detail 为什么要拆分？（冷热分离）
- 文章缓存是如何管理的？（ArticleCacheManager）
- 文章阅读计数如何实现？（异步 + Redis 累加 + 批量入库）

**练习**：
- 新增一个文章类型（如"教程"），需要修改哪些文件？
- 实现一个"热门文章"接口

### 4.2 用户与认证系统（必读）

**源码阅读路线**：

```
1. 认证流程
   ├── LoginService.java（登录逻辑）
   ├── ReqRecordFilter.java（Token 提取）
   ├── GlobalInitService.java（用户信息初始化）
   └── GlobalViewInterceptor.java（权限校验）

2. 用户信息
   ├── UserService.java（用户服务）
   ├── UserInfoCacheManager.java（用户缓存）
   └── UserFootService.java（用户足迹）

3. 前端
   ├── LoginDialog.vue（登录弹窗）
   ├── BackendRequests.ts（请求拦截器，自动附加Token）
   └── stores/global.ts（全局状态管理）
```

**重点理解**：
- JWT Token 的生成、传递、验证流程
- ReqInfoContext 如何在异步线程中传递（TransmittableThreadLocal）
- @Permission 注解的权限校验机制

**练习**：
- 实现一个"记住我"功能（延长 JWT 有效期）
- 新增一个角色（如"版主"），实现角色权限控制

### 4.3 评论系统

**源码阅读路线**：

```
1. 数据库层
   ├── comment 表结构（支持多级评论：top_comment_id + parent_comment_id）
   └── CommentMapper.xml

2. 服务层
   ├── CommentReadService.java（评论读取）
   └── CommentWriteService.java（评论写入）

3. 前端
   ├── CommentItem.vue（评论项组件）
   ├── SubCommentAction.vue（子评论组件）
   └── CommentList.vue（评论列表）
```

**重点理解**：
- 多级评论的数据结构设计
- 评论与通知的联动（评论后自动发通知）

### 4.4 通知系统

**源码阅读路线**：

```
1. 服务层
   ├── NotifyService.java（通知服务）
   └── RabbitmqService.java（异步通知）

2. 消息队列
   ├── NotifyMsgListener.java（消息监听）
   └── MessageQueueNotifyMsgConsumer.java（消息消费）

3. 前端
   ├── NoticeView.vue（通知页面）
   └── notice/ 目录下的6种通知组件
```

**重点理解**：
- 6种通知类型的设计（枚举 + 独立组件）
- RabbitMQ 异步通知 vs 同步通知的切换机制
- 未读消息计数的实时更新

---

## 五、阶段4：扩展功能与高级特性

### 5.1 缓存体系

**学习目标**：理解双层缓存的设计与实现。

**源码阅读路线**：

```
1. 核心类
   ├── RedisClient.java（Redis 操作封装）
   ├── CacheSyncUtil.java（缓存同步）
   └── ForumCoreAutoConfig.java（Caffeine 配置）

2. 缓存注解
   ├── @CacheKey（缓存键）
   ├── @CacheValue（缓存值）
   └── @CacheType（缓存类型）

3. 缓存管理器
   ├── ArticleCacheManager.java（文章缓存）
   └── UserInfoCacheManager.java（用户缓存）
```

**练习**：
- 为分类列表添加缓存
- 实现缓存预热功能（应用启动时加载热点数据）

### 5.2 多数据源

**源码阅读路线**：

```
1. DataSourceConfig.java（数据源配置）
2. MyRoutingDataSource.java（路由数据源）
3. DsAspect.java（数据源切换切面）
4. DsContextHolder.java（数据源上下文）
5. @DS 注解（数据源标记）
```

**练习**：
- 配置一主一从数据源
- 实现读写分离：写操作走主库，读操作走从库

### 5.3 AI 聊天

**源码阅读路线**：

```
1. 后端
   ├── WsChatConfig.java（WebSocket 配置）
   ├── AuthHandshakeInterceptor.java（握手认证）
   ├── WsAnswerHelper.java（AI 回答辅助）
   ├── SimpleChatgptHandler.java（ChatGPT 处理器）
   └── UserAiService.java（AI 策略管理）

2. 前端
   ├── ChatView.vue（聊天页面）
   └── ChatSideBar.vue（聊天侧边栏）
```

**重点理解**：
- STOMP 协议在 WebSocket 中的应用
- 流式响应（STREAM）的实现方式
- AI 模型策略的切换机制

### 5.4 图片上传

**源码阅读路线**：

```
1. ImageService.java（图片服务接口）
2. ImageUploader.java（上传接口）
3. AliOssWrapper.java（阿里云 OSS 实现）
4. LocalStorageWrapper.java（本地存储实现）
```

**重点理解**：
- 策略模式在存储实现中的应用
- 通过配置切换存储方式（local/aliyun）

---

## 六、阶段5：实战练习

### 6.1 入门级练习

| 练习 | 涉及模块 | 难度 |
|------|---------|------|
| 新增一个文章分类 | service + web + front | ⭐ |
| 实现文章搜索功能 | service + elasticsearch | ⭐⭐ |
| 新增一种通知类型 | api + service + web + front | ⭐⭐ |
| 实现用户签名功能 | api + service + web + front | ⭐ |

### 6.2 进阶级练习

| 练习 | 涉及模块 | 难度 |
|------|---------|------|
| 实现文章草稿功能 | api + service + web + front | ⭐⭐⭐ |
| 实现评论点赞功能 | service + cache + front | ⭐⭐⭐ |
| 实现接口限流 | core + web | ⭐⭐⭐ |
| 实现分布式 Session | core + redis | ⭐⭐⭐ |

### 6.3 高级练习

| 练习 | 涉及模块 | 难度 |
|------|---------|------|
| 实现全文搜索高亮 | service + elasticsearch | ⭐⭐⭐⭐ |
| 实现实时消息推送 | websocket + rabbitmq | ⭐⭐⭐⭐ |
| 实现灰度发布 | config + gateway | ⭐⭐⭐⭐ |
| 实现分布式链路追踪 | core + micrometer | ⭐⭐⭐⭐⭐ |

---

## 七、核心源码阅读清单

### 7.1 必读源码（按优先级排序）

| 优先级 | 文件 | 关键知识点 |
|--------|------|-----------|
| P0 | QuickForumApplication.java | 启动流程 |
| P0 | ReqRecordFilter.java | 请求过滤与上下文初始化 |
| P0 | GlobalViewInterceptor.java | 权限拦截 |
| P0 | ReqInfoContext.java | 请求上下文（TTL） |
| P0 | ResVo.java | 统一响应 |
| P1 | LoginService.java | 登录认证 |
| P1 | ArticleReadService.java | 文章读取 |
| P1 | ArticleWriteService.java | 文章写入 |
| P1 | UserFootService.java | 用户足迹 |
| P1 | NotifyService.java | 通知系统 |
| P2 | DataSourceConfig.java | 多数据源 |
| P2 | RedisClient.java | Redis 封装 |
| P2 | ArticleCacheManager.java | 缓存管理 |
| P2 | WsChatConfig.java | WebSocket |
| P2 | RabbitmqService.java | 消息队列 |

### 7.2 前端必读源码

| 优先级 | 文件 | 关键知识点 |
|--------|------|-----------|
| P0 | main.ts | 入口配置 |
| P0 | router/index.ts | 路由结构 |
| P0 | http/BackendRequests.ts | HTTP 封装 |
| P0 | http/URL.ts | API 地址 |
| P0 | stores/global.ts | 全局状态 |
| P1 | views/HomeView.vue | 首页 |
| P1 | views/ArticleDetailView.vue | 文章详情 |
| P1 | components/dialog/LoginDialog.vue | 登录弹窗 |
| P2 | views/ChatView.vue | AI 聊天 |
| P2 | views/NoticeView.vue | 通知系统 |

---

## 八、常见问题与排错指南

### 8.1 启动问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 数据库连接失败 | MySQL 未启动或密码错误 | 检查 application-dal.yml 配置 |
| Redis 连接失败 | Redis 未启动 | 启动 Redis 服务 |
| 端口被占用 | 8081 端口已被占用 | 修改 application-web.yml 中的端口 |
| Liquibase 报错 | 数据库版本冲突 | 清空 DATABASECHANGELOG 表重试 |

### 8.2 前端问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| API 请求 404 | 后端未启动 | 先启动后端 |
| 跨域错误 | Vite 代理配置错误 | 检查 vite.config.ts 中的 proxy |
| 页面空白 | 路由配置错误 | 检查 router/index.ts |
| 登录状态丢失 | Token 过期 | 清除 localStorage 重新登录 |

### 8.3 调试技巧

**后端调试**：
1. 在 IDEA 中使用 Debug 模式启动
2. 在 ReqRecordFilter 中设置条件断点（如特定 URL）
3. 使用 Actuator 端点查看应用状态：`/actuator/health`

**前端调试**：
1. 使用 Vue DevTools 浏览器扩展
2. 在 Network 面板查看 API 请求和响应
3. 在 Console 中查看 WebSocket 消息

---

## 九、技术栈深入学习资源

### 9.1 后端技术栈

| 技术 | 官方文档 | 推荐书籍 |
|------|---------|---------|
| Spring Boot 3 | spring.io/projects/spring-boot | 《Spring Boot 实战》 |
| MyBatis-Plus | baomidou.com | 《MyBatis-Plus 官方文档》 |
| Redis | redis.io | 《Redis 设计与实现》 |
| Elasticsearch | elastic.co | 《Elasticsearch 权威指南》 |
| RabbitMQ | rabbitmq.com | 《RabbitMQ 实战》 |
| JWT | jwt.io | 《JWT 完整指南》 |
| Liquibase | liquibase.org | 官方文档 |

### 9.2 前端技术栈

| 技术 | 官方文档 | 推荐资源 |
|------|---------|---------|
| Vue 3 | vuejs.org | 《Vue.js 设计与实现》 |
| TypeScript | typescriptlang.org | 《TypeScript 编程》 |
| Vite | vitejs.dev | 官方文档 |
| Pinia | pinia.vuejs.org | 官方文档 |
| Element Plus | element-plus.org | 官方文档 |
| Tailwind CSS | tailwindcss.com | 官方文档 |

---

## 十、学习里程碑检查清单

- [ ] 能独立搭建开发环境并运行项目
- [ ] 能说出四个后端模块的职责和依赖关系
- [ ] 能画出 HTTP 请求的完整处理链路
- [ ] 能解释 JWT 认证流程
- [ ] 能理解双层缓存的设计思路
- [ ] 能阅读文章模块的源码并理解核心逻辑
- [ ] 能理解多数据源的实现原理
- [ ] 能理解 WebSocket 聊天的实现方案
- [ ] 能独立完成一个入门级功能扩展
- [ ] 能在面试中流畅介绍项目架构和设计
