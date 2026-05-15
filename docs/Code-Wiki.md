# 技术派（paicoding-forum）Code Wiki

> 基于 Spring Boot 3 + Vue 3 的现代化技术社区系统

---

## 一、项目概述

技术派是一个面向开发者的技术社区平台，支持文章发布、专栏管理、评论互动、消息通知、AI 聊天等核心功能。项目采用前后端分离架构，后端基于 Spring Boot 3 + MyBatis-Plus，前端基于 Vue 3 + TypeScript + Vite。

### 技术栈总览

| 层级 | 后端技术 | 前端技术 |
|------|---------|---------|
| 框架 | Spring Boot 3.0.9 | Vue 3.4 |
| 语言 | Java 17 | TypeScript 5.4 |
| ORM | MyBatis-Plus 3.5.4 | Axios |
| 缓存 | Redis + Caffeine | Pinia |
| 搜索 | Elasticsearch 6.8 | - |
| 消息队列 | RabbitMQ | - |
| 构建 | Maven | Vite 5 |
| 认证 | JWT (auth0 4.4.0) | JWT Token |
| API文档 | Knife4j 4.5 | - |
| 对象存储 | 阿里云 OSS / 本地 | - |
| 数据库版本 | Liquibase | - |
| UI组件 | - | Element Plus + Tailwind CSS |
| Markdown | Flexmark | md-editor-v3 |
| 实时通信 | WebSocket (STOMP) | SockJS + Stomp.js |

---

## 二、项目架构

### 2.1 整体架构图

```
┌──────────────────────────────────────────────────────────────┐
│                        用户浏览器                              │
│                   Vue 3 SPA (Port 80/443)                     │
└────────────────────────┬─────────────────────────────────────┘
                         │ HTTP / WebSocket
                         ▼
┌──────────────────────────────────────────────────────────────┐
│                     Nginx 反向代理                             │
│  /           → 前端静态文件                                     │
│  /api/       → 后端 API 代理                                   │
│  /ws/        → WebSocket 代理                                  │
│  /upload/    → 文件上传代理                                     │
└────────────────────────┬─────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Spring Boot │ │   MySQL 8    │ │    Redis     │
│  (Port 8081) │ │  (Port 3306) │ │  (Port 6379) │
└──────┬───────┘ └──────────────┘ └──────────────┘
       │
       ├──────────────┬──────────────┐
       ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│Elasticsearch │ │  RabbitMQ    │ │  阿里云 OSS   │
│ (Port 9200)  │ │ (Port 5672)  │ │  (可选)       │
└──────────────┘ └──────────────┘ └──────────────┘
```

### 2.2 后端模块架构

```
paicoding-web (Web入口层)
    ├── controller/     → REST API 控制器
    ├── hook/           → 拦截器、过滤器
    ├── global/         → 全局异常处理、初始化
    ├── config/         → Web 配置
    ├── chat/           → WebSocket 聊天
    └── mq/             → 消息队列消费者
    │
    └── paicoding-service (业务服务层)
        ├── article/    → 文章/标签/分类/专栏
        ├── user/       → 用户/登录/注册/足迹/关系
        ├── comment/    → 评论
        ├── notify/     → 通知
        ├── statistics/ → 统计/计数
        ├── rank/       → 排行
        ├── image/      → 图片上传
        └── sitemap/    → 站点地图
        │
        └── paicoding-core (核心组件层)
            ├── dal/        → 数据源配置(主从)
            ├── cache/      → 缓存(Redis+Caffeine)
            ├── permission/ → 权限控制
            ├── sensitive/  → 敏感词过滤
            ├── async/      → 异步执行
            ├── mq/         → RabbitMQ 配置
            └── util/       → 工具类集合
            │
            └── paicoding-api (基础定义层)
                ├── model/      → 实体/DTO/VO/上下文
                ├── enums/      → 枚举定义(40+)
                ├── exception/  → 异常体系
                └── event/      → 事件定义
```

### 2.3 模块依赖关系

```
paicoding-web
    └── paicoding-service
            └── paicoding-core
                    └── paicoding-api
```

依赖方向严格单向：api → core → service → web，上层依赖下层，下层不感知上层。

---

## 三、模块职责详解

### 3.1 paicoding-api（基础定义层）

**职责**：定义全局通用的模型、枚举、异常和事件，不包含任何业务逻辑。

| 子包 | 职责 | 关键类 |
|------|------|--------|
| model/context | 请求上下文 | ReqInfoContext（基于TTL的ThreadLocal） |
| model/vo | 视图对象 | ResVo（统一响应）、PageVo/PageListVo（分页） |
| model/dto | 数据传输对象 | 各业务DTO |
| model/entity | 数据库实体 | Article、User、Comment等 |
| enums | 枚举定义 | PushStatusEnum、NotifyTypeEnum等40+枚举 |
| exception | 异常体系 | ForumException、ForumAdviceException |
| event | 事件定义 | ArticleMsgEvent、ConfigRefreshEvent |

**核心类说明**：

- `ReqInfoContext`：基于 TransmittableThreadLocal 的请求上下文，存储当前请求的用户信息、session、IP、路径等，支持异步线程传递
- `ResVo<T>`：统一API响应封装，包含 Status + result，提供 ok()/fail() 静态方法
- `PageParam/PageVo/PageListVo`：分页参数与结果封装

### 3.2 paicoding-core（核心组件层）

**职责**：提供通用基础设施，包括数据源、缓存、权限、敏感词、异步、消息队列等。

| 子包 | 职责 | 关键类 |
|------|------|--------|
| dal | 数据源配置 | DataSourceConfig、MyRoutingDataSource、DsAspect、@DS |
| cache | 缓存体系 | RedisClient、CacheSyncUtil、@CacheKey/@CacheValue |
| permission | 权限控制 | @Permission(role=ALL/LOGIN/ADMIN)、UserRole |
| sensitive | 敏感词 | SensitiveService、SensitiveReadInterceptor、@SensitiveField |
| async | 异步执行 | AsyncUtil、@AsyncExecute、AsyncExecuteAspect |
| mq | 消息队列 | RabbitMqConfig、RabbitmqConnectionPool |
| util | 工具类 | SpringUtil、IpUtil、SessionUtil、MarkdownConverter、SnowflakeProducer |

**核心设计**：

1. **多数据源**：自定义 MyRoutingDataSource + @DS 注解实现主从读写分离，DsAspect 切面动态切换数据源
2. **双层缓存**：Caffeine 本地缓存 + Redis 分布式缓存，CacheSyncUtil 保证一致性
3. **权限注解**：@Permission(role=ADMIN/LOGIN/ALL) 声明式权限控制，GlobalViewInterceptor 负责拦截校验
4. **敏感词**：MyBatis 读取拦截器自动脱敏，@SensitiveField 标记敏感字段
5. **异步执行**：@AsyncExecute 注解 + AOP 切面，简化异步调用

### 3.3 paicoding-service（业务服务层）

**职责**：实现所有业务逻辑，包括文章、用户、评论、通知、统计、排行、图片等。

#### 文章模块（article）

| 类 | 职责 |
|----|------|
| ArticleReadService | 文章读取：详情/列表/热门/搜索/分类/标签 |
| ArticleWriteService | 文章写入：保存/删除文章 |
| ArticleRecommendService | 文章推荐 |
| ArticleSettingService | 文章后台管理 |
| TagService / TagSettingService | 标签服务/管理 |
| CategoryService / CategorySettingService | 分类服务/管理 |
| ColumnService / ColumnSettingService | 专栏服务/管理 |
| ArticleCacheManager | 文章缓存管理器 |

#### 用户模块（user）

| 类 | 职责 |
|----|------|
| UserService | 用户基础服务 |
| LoginService | 登录服务（微信/账号密码） |
| RegisterService | 注册服务 |
| UserFootService | 用户足迹（点赞/收藏/阅读/评论状态） |
| UserRelationService | 用户关系（关注/粉丝） |
| UserAiService | AI 聊天策略管理 |
| UserInfoCacheManager | 用户信息缓存 |

#### 其他模块

| 模块 | 关键类 | 职责 |
|------|--------|------|
| 评论 | CommentReadService / CommentWriteService | 评论CRUD |
| 通知 | NotifyService / RabbitmqService | 通知与消息队列 |
| 统计 | CountService / RequestCountService / UserStatisticService | 计数/PV/UV/在线统计 |
| 排行 | UserActivityRankService | 用户活跃度排行 |
| 图片 | ImageService / AliOssWrapper / LocalStorageWrapper | 图片上传（OSS/本地） |
| 站点 | SitemapService | 站点地图与统计 |

### 3.4 paicoding-web（Web入口层）

**职责**：HTTP入口，包含控制器、拦截器、过滤器、配置、WebSocket等。

#### 前台 Controller

| Controller | 路径前缀 | 职责 |
|-----------|---------|------|
| ArticleRestController | /article/api | 文章API |
| ArticleListRestController | /article/api | 文章列表API |
| ColumnRestController | /column/api | 专栏API |
| CommentRestController | /comment/api | 评论API |
| NoticeRestController | /notice/api | 通知API |
| UserRestController | /user/api | 用户API |
| TagRestController | /api/tag | 标签API |
| CategoryRestController | /api/category | 分类API |
| SearchRestController | /search/api | 搜索API |
| ChatRestController | /chat/api | AI聊天API |
| GlobalInfoController | /api/global | 全局信息API |
| LoginRestController | /new/login | 登录API |
| WxLoginController | /wx | 微信登录 |
| ImageRestController | /image | 图片上传API |

#### 后台 Controller（admin）

| Controller | 职责 |
|-----------|------|
| AdminLoginController | 后台登录 |
| ArticleSettingRestController | 文章管理 |
| CategorySettingRestController | 分类管理 |
| TagSettingRestController | 标签管理 |
| ColumnSettingRestController | 专栏管理 |
| GlobalConfigRestController | 全局配置 |
| StatisticsSettingRestController | 统计设置 |
| UserSettingRestController | 用户管理 |

#### 请求处理链路

```
HTTP 请求
  → ReqRecordFilter.doFilter()         // 初始化上下文、识别登录用户、CORS、traceId
  → GlobalViewInterceptor.preHandle()  // 权限校验(@Permission)、活跃度更新
  → Controller 方法                     // 业务处理
  → GlobalExceptionHandler             // 异常兜底
```

---

## 四、数据库设计

### 4.1 核心数据表（16张）

#### 文章相关

| 表名 | 说明 | 关键字段 |
|------|------|---------|
| article | 文章表 | id, user_id, article_type, title, short_title, picture, summary, category_id, source, status |
| article_detail | 文章详情表 | id, article_id, version, content(longtext) |
| article_tag | 文章-标签映射 | id, article_id, tag_id |
| tag | 标签表 | id, tag_name, tag_type, category_id, status |
| category | 分类表 | id, category_name, status, rank |
| column_info | 专栏表 | id, column_name, user_id, introduction, cover, state |
| column_article | 专栏文章列表 | id, column_id, article_id, section, read_type |

#### 用户相关

| 表名 | 说明 | 关键字段 |
|------|------|---------|
| user | 用户登录表 | id, third_account_id, user_name, password, login_type |
| user_info | 用户信息表 | id, user_id, user_name, photo, position, company, profile, user_role, ip |
| user_foot | 用户足迹表 | id, user_id, document_id, document_type, collection_stat, read_stat, comment_stat, praise_stat |
| user_relation | 用户关系表 | id, user_id, follow_user_id, follow_state |
| user_ai | AI聊天运营表 | id, user_id, star_number, star_type, invite_code, strategy |
| user_ai_history | AI聊天历史 | id, user_id, ai_type, question, answer |

#### 互动相关

| 表名 | 说明 | 关键字段 |
|------|------|---------|
| comment | 评论表 | id, article_id, user_id, content, top_comment_id, parent_comment_id |
| notify_msg | 消息通知表 | id, related_id, notify_user_id, operate_user_id, msg, type, state |

#### 统计与配置

| 表名 | 说明 | 关键字段 |
|------|------|---------|
| read_count | 计数表 | id, document_id, document_type, cnt |
| request_count | 请求计数表 | id, host, cnt, date |
| config | 配置表 | id, type, name, banner_url, jump_url, content, rank, status |

### 4.2 表关系

```
user (1) ──── (N) article           : 用户发布文章
user (1) ──── (N) comment           : 用户发表评论
user (1) ──── (N) user_foot         : 用户足迹记录
user (1) ──── (N) user_relation     : 用户关注关系
user (1) ──── (1) user_ai           : 用户AI策略

article (1) ── (1) article_detail   : 文章详情（版本化）
article (1) ── (N) article_tag      : 文章标签映射
article (1) ── (N) comment          : 文章评论
article (1) ── (N) user_foot        : 文章用户交互
article (1) ── (N) read_count       : 文章阅读计数

tag (N) ────── (N) article          : 通过 article_tag 关联
category (1) ── (N) article         : 分类下的文章
category (1) ── (N) tag             : 分类下的标签

column_info (1) ── (N) column_article : 专栏包含文章
column_article (N) ── (1) article     : 专栏文章关联
```

---

## 五、前端架构

### 5.1 目录结构

```
pai-coding-front/
├── src/
│   ├── assets/          → 静态资源（CSS/图片）
│   ├── components/      → 可复用组件
│   │   ├── article/     → 文章组件
│   │   ├── column/      → 专栏组件
│   │   ├── comment/     → 评论组件
│   │   ├── dialog/      → 弹窗组件
│   │   ├── layout/      → 布局组件（HeaderBar/Footer）
│   │   ├── notice/      → 通知组件（6种类型）
│   │   ├── side/        → 侧边栏组件
│   │   └── user/        → 用户组件
│   ├── constants/       → 常量/枚举定义
│   ├── http/            → HTTP 封装层
│   │   ├── URL.ts       → API 地址常量
│   │   ├── BackendRequests.ts → Axios 封装
│   │   └── ResponseTypes/     → TypeScript 类型定义
│   ├── router/          → 路由配置
│   ├── stores/          → Pinia 状态管理
│   ├── util/            → 工具函数
│   ├── views/           → 页面视图
│   ├── App.vue          → 根组件
│   └── main.ts          → 入口文件
├── .env.development     → 开发环境配置
├── .env.production      → 生产环境配置
├── vite.config.ts       → Vite 构建配置
└── package.json         → 依赖管理
```

### 5.2 路由结构

| 路径 | 组件 | 说明 |
|------|------|------|
| / | HomeView | 首页（文章列表+推荐） |
| /article/detail/:articleId | ArticleDetailView | 文章详情 |
| /article/edit | ArticleEditView | 新建文章 |
| /article/edit/:articleId | ArticleEditView | 编辑文章 |
| /article/tag/:tagId | TagArticlesView | 标签文章 |
| /column | ColumnView | 专栏首页 |
| /column/:columnId/:sectionId | ColumnDetailView | 专栏详情 |
| /chat | ChatView | AI聊天 |
| /user/:userId/:typeName | UserHomeView | 用户主页 |
| /notice/:noticeType | NoticeView | 通知页 |
| /tools/excel | ToolsExcel | Excel工具 |

### 5.3 状态管理

核心全局 Store（Pinia）：

```typescript
GlobalResponse {
  siteInfo            // 站点信息
  siteStatisticInfo   // 站点统计（PV/UV）
  isLogin             // 登录状态
  user                // 当前用户信息
  msgNum              // 未读消息数
  onlineCnt           // 在线人数
}
```

### 5.4 组件通信模式

- **Pinia Store**：全局状态共享（用户信息、登录状态、站点信息）
- **provide/inject**：登录弹窗跨层级触发
- **Props 传递**：文章详情、评论列表等数据向下传递

---

## 六、配置体系

### 6.1 后端配置层次

```
application.yml                    # 主配置（入口）
├── application-config.yml         # 站点视图配置
├── application-email.yml          # 邮件配置
├── application-dal.yml            # 数据源+Redis+ES（按环境）
├── application-web.yml            # Web配置（按环境）
├── application-ai.yml             # AI模型配置（按环境）
├── application-image.yml          # 图片存储配置（按环境）
└── application-rabbitmq.yml       # RabbitMQ配置（按环境）
```

### 6.2 环境切换

通过 Maven Profile 实现（dev/test/pre/prod）：

```bash
mvn clean package -Pdev    # 开发环境
mvn clean package -Ptest   # 测试环境
mvn clean package -Ppre    # 预发环境
mvn clean package -Pprod   # 生产环境
```

### 6.3 关键配置项

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| server.port | 8081 | 服务端口 |
| database.name | pai_coding_2026 | 数据库名 |
| security.salt | tech_pi | 密码加盐 |
| paicoding.jwt.expire | 2592000000 | JWT有效期(30天) |
| paicoding.sensitive.enable | true | 敏感词过滤 |
| elasticsearch.open | false | ES开关 |
| rabbitmq.switchFlag | false | RabbitMQ开关 |
| image.oss.type | local | 图片存储方式 |

---

## 七、部署与运行

### 7.1 本地开发

```bash
# 后端
git clone <repo>
cd paicoding
# 修改 paicoding-web/src/main/resources-env/dev/application-dal.yml 数据库配置
# 在 IDEA 中运行 QuickForumApplication（默认 dev 环境，端口 8081）

# 前端
cd pai-coding-front
npm install
npm run dev    # 默认代理到 http://localhost:8081
```

### 7.2 Docker 部署

```bash
# 编译 jar
mvn clean package -DskipTests -Pprod

# 配置环境变量
cd docker
cp .env.example .env
vim .env

# 启动
docker-compose up -d
```

### 7.3 源码构建部署

```bash
chmod +x launch.sh
./launch.sh start     # git pull + 编译 + 启动
./launch.sh restart   # 仅重启
```

### 7.4 前端构建

```bash
npm run build:prod      # 生产构建
npm run build:github    # GitHub Pages 构建
```

---

## 八、架构设计亮点

1. **分层清晰**：api(定义) → core(基础设施) → service(业务) → web(入口)，依赖单向
2. **多数据源**：MyRoutingDataSource + @DS 注解实现主从读写分离
3. **策略模式**：在线统计支持 AtomicInteger/Caffeine/Redis 三种实现
4. **权限注解**：@Permission 声明式权限控制
5. **请求上下文**：ReqInfoContext 基于 TTL，支持异步线程传递
6. **双层缓存**：Caffeine 本地 + Redis 分布式
7. **消息驱动**：RabbitMQ 异步处理通知和活跃度
8. **AI 集成**：ChatGPT/讯飞/自研 AI，策略可配置
9. **数据库版本管理**：Liquibase 自动建库建表
10. **环境隔离**：4套环境配置，敏感信息环境变量注入
