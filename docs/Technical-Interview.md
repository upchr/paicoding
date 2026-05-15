# 技术派项目 — 技术面试指南

> 面向 Java 后端开发 & 全栈开发岗位，基于技术派项目深度剖析

---

## 一、项目架构类面试题

### Q1：请介绍一下技术派项目的整体架构

**参考答案**：

技术派采用前后端分离架构，后端基于 Spring Boot 3，前端基于 Vue 3。

后端分为四层模块：
- **paicoding-api**：最底层基础定义层，包含枚举、实体类、DTO/VO、异常定义、请求上下文，无内部依赖
- **paicoding-core**：核心组件层，提供数据源配置、缓存、权限、敏感词、异步执行、消息队列等基础设施
- **paicoding-service**：业务服务层，实现文章、用户、评论、通知、统计、排行等所有业务逻辑
- **paicoding-web**：Web入口层，包含Controller、拦截器、过滤器、WebSocket等

依赖关系严格单向：web → service → core → api，上层依赖下层，下层不感知上层。

前端使用 Vue 3 + TypeScript + Vite 构建，Pinia 状态管理，Element Plus + Tailwind CSS 做UI，通过 Axios 封装 HTTP 请求，SockJS + Stomp.js 实现 WebSocket 实时通信。

**面试要点**：强调分层的好处——职责清晰、依赖单向、易于测试和维护。

---

### Q2：为什么采用这种分层架构？有什么好处？

**参考答案**：

1. **职责单一**：每层只关注自己的职责，api层定义数据结构，core层提供基础设施，service层实现业务，web层处理HTTP
2. **依赖单向**：依赖方向 api ← core ← service ← web，避免了循环依赖
3. **易于替换**：比如将 MyBatis-Plus 换成 JPA，只需修改 service 层的 DAO 实现
4. **便于测试**：service 层可以独立于 web 层进行单元测试
5. **团队协作**：不同团队可以并行开发不同层

**延伸**：这也是 DDD（领域驱动设计）思想的简化实践，api 层相当于领域模型层。

---

### Q3：项目中的多数据源是如何实现的？

**参考答案**：

项目通过自定义 `MyRoutingDataSource` 继承 `AbstractRoutingDataSource`，配合 `@DS` 注解和 `DsAspect` 切面实现动态数据源切换。

核心流程：
1. `DataSourceConfig` 配置 Master 和 Slave 两个数据源
2. `MyRoutingDataSource` 根据 `DsContextHolder` 中的 key 路由到对应数据源
3. `@DS` 注解标记在方法或类上，指定使用 master 还是 slave
4. `DsAspect` 在方法执行前设置数据源 key，执行后清除

```java
@DS("slave")
public ArticleDTO queryArticle(Long id) {
    // 使用从库查询
}
```

**面试要点**：这是 Spring AbstractRoutingDataSource 的经典应用，注意 ThreadLocal 的清理，避免线程复用导致的数据源错乱。

---

## 二、缓存设计类面试题

### Q4：项目中的缓存架构是怎样的？

**参考答案**：

采用 Caffeine 本地缓存 + Redis 分布式缓存的双层架构：

- **L1 缓存（Caffeine）**：JVM 本地缓存，访问速度极快，但无法跨实例共享
- **L2 缓存（Redis）**：分布式缓存，跨实例共享，支持过期和淘汰策略

缓存一致性保证：
- `CacheSyncUtil` 负责缓存同步，当数据更新时同步更新/失效缓存
- `@CacheKey`/`@CacheValue`/`@CacheType` 注解简化缓存操作

典型场景：文章详情缓存、用户信息缓存、全局配置缓存。

**面试要点**：双层缓存的经典问题——缓存一致性。项目通过 CacheSyncUtil 在写入时同步更新缓存，属于"写时更新"策略。

---

### Q5：如何保证缓存与数据库的一致性？

**参考答案**：

项目采用"写时更新"策略：

1. **写入流程**：先更新数据库，再通过 CacheSyncUtil 更新/失效缓存
2. **读取流程**：先查 L1 缓存，未命中查 L2 缓存，再未命中查数据库，结果回填缓存
3. **异常处理**：缓存更新失败时记录日志，不影响主流程

这种策略的权衡：
- 优点：读取性能最优，缓存始终有数据
- 缺点：极端并发下可能出现短暂不一致（数据库更新成功但缓存更新失败）
- 改进方向：可引入消息队列异步更新缓存，或使用 Canal 监听 binlog

---

## 三、认证与安全类面试题

### Q6：JWT 认证流程是怎样的？

**参考答案**：

1. 用户登录（微信/账号密码），服务端验证成功后生成 JWT Token
2. Token 通过 Cookie 或 Authorization 头返回给客户端
3. 后续请求中，`ReqRecordFilter` 从 Cookie 或 Authorization 头提取 Token
4. `GlobalInitService.initLoginUser()` 解析 Token，查询用户信息，存入 ReqInfoContext
5. `GlobalViewInterceptor` 根据 @Permission 注解校验权限

JWT 配置：
- 签发者：pai_coding
- 有效期：30天（2592000000ms）
- 密码加盐：tech_pi

**面试要点**：JWT 无状态，服务端不存储 Session，适合分布式部署。但无法主动失效，可通过黑名单机制弥补。

---

### Q7：权限控制是如何实现的？

**参考答案**：

通过自定义 `@Permission` 注解 + 拦截器实现声明式权限控制：

```java
@Permission(role = UserRole.ADMIN)
public ResVo<?> adminApi() { ... }

@Permission(role = UserRole.LOGIN)
public ResVo<?> loginApi() { ... }
```

三种角色级别：
- `ALL`：无需登录即可访问
- `LOGIN`：需要登录才能访问
- `ADMIN`：需要管理员权限

拦截流程：`GlobalViewInterceptor.preHandle()` 读取方法上的 @Permission 注解，根据角色要求检查 ReqInfoContext 中的用户信息。

---

### Q8：敏感词过滤是如何实现的？

**参考答案**：

项目使用 `sensitive-word` 库实现敏感词过滤，采用 MyBatis 拦截器自动脱敏：

1. `@SensitiveField` 注解标记需要脱敏的实体字段
2. `SensitiveReadInterceptor` 作为 MyBatis 拦截器，在读取时自动对敏感字段进行脱敏
3. `SensitiveService` 封装敏感词检测和替换逻辑

这种设计的优势：业务代码无需关心脱敏逻辑，通过注解声明式配置，AOP 自动处理。

---

## 四、消息队列类面试题

### Q9：RabbitMQ 在项目中的应用场景？

**参考答案**：

RabbitMQ 主要用于两个异步场景：

1. **通知消息异步处理**：用户点赞/评论/关注后，通过 RabbitMQ 异步发送通知，避免阻塞主流程
2. **用户活跃度更新**：用户操作后，异步更新活跃度排行

架构设计：
- `RabbitmqService`：消息生产者
- `NotifyMsgListener`/`MessageQueueNotifyMsgConsumer`：通知消息消费者
- `MessageQueueUserActivityConsumer`：活跃度消费者
- `RabbitmqConnectionPool`：连接池管理

**关键设计**：RabbitMQ 通过 `rabbitmq.switchFlag` 配置开关控制，关闭时走同步逻辑，降低部署依赖。

---

## 五、数据库设计类面试题

### Q10：文章表为什么拆分为 article 和 article_detail？

**参考答案**：

这是典型的"冷热分离"设计：

- **article 表**：存储文章列表需要展示的字段（标题、摘要、封面、分类等），数据量小，查询频繁
- **article_detail 表**：存储文章正文（longtext），数据量大，只在查看详情时加载

好处：
1. **查询性能**：列表查询不需要加载大字段，减少 IO 和内存占用
2. **缓存效率**：article 表数据小，缓存命中率高
3. **更新隔离**：修改正文不影响列表数据，减少缓存失效

**面试要点**：这是数据库优化的经典手法——垂直拆分，将大字段独立成表。

---

### Q11：用户足迹表(user_foot)的设计思路？

**参考答案**：

user_foot 表记录用户与文档（文章/评论）的交互状态：

| 字段 | 说明 |
|------|------|
| user_id | 操作用户 |
| document_id | 文档ID（文章或评论） |
| document_type | 文档类型（1-文章，2-评论） |
| document_user_id | 文档作者 |
| praise_stat | 点赞状态 |
| collection_stat | 收藏状态 |
| read_stat | 阅读状态 |
| comment_stat | 评论状态 |

设计亮点：
1. **多态设计**：document_id + document_type 实现一表管理多种文档类型的交互
2. **状态冗余**：将点赞/收藏/阅读/评论状态集中在一行，查询一次即可获取所有状态
3. **反向查询**：document_user_id 字段方便查询"谁对我的文章做了什么"

---

## 六、高并发与性能类面试题

### Q12：在线用户统计是如何实现的？

**参考答案**：

采用策略模式，支持三种实现，通过配置切换：

1. **AtomicInteger**：最简单的内存计数器，适合单机部署
2. **Caffeine**：基于 Caffeine 缓存的过期计数，支持时间窗口
3. **Redis**：分布式计数，适合多实例部署

通过 `online.statistics.type` 配置项选择策略，`UserStatisticService` 接口定义统一契约。

**面试要点**：策略模式 + 配置化切换，是开闭原则的典型应用。

---

### Q13：文章阅读计数如何保证性能？

**参考答案**：

1. **异步计数**：阅读计数通过异步方式更新，不阻塞文章阅读主流程
2. **缓存计数**：先在 Redis 中累加计数，定时批量写入数据库
3. **read_count 表**：独立计数表，避免在 article 表上频繁更新

这种设计将"读"和"写"分离，读取走缓存，写入走异步批量，最大化性能。

---

## 七、WebSocket 实时通信类面试题

### Q14：AI 聊天的 WebSocket 实现方案？

**参考答案**：

后端：
- `WsChatConfig`/`SimpleWsConfig`：WebSocket 配置，使用 STOMP 协议
- `AuthHandshakeInterceptor`：握手阶段认证
- `AuthInChannelInterceptor`/`AuthOutChannelInterceptor`：消息收发拦截
- `WsAnswerHelper`：AI 回答辅助，支持流式响应
- `SimpleChatgptHandler`：ChatGPT 处理器

前端：
- SockJS + Stomp.js 建立 WebSocket 连接
- 支持 STREAM（流式）和 JSON 两种响应模式
- 流式模式下逐字显示 AI 回答，提升用户体验

AI 策略：
- 支持 ChatGPT 3.5/4、讯飞星火、自研 AI
- 通过配置切换主力模型
- 有每日对话次数限制

---

## 八、设计模式类面试题

### Q15：项目中用到了哪些设计模式？

**参考答案**：

| 设计模式 | 应用场景 | 说明 |
|---------|---------|------|
| 策略模式 | 在线统计、AI模型选择 | 通过配置切换不同实现 |
| 模板方法 | BaseService | 抽象公共逻辑，子类实现差异 |
| 观察者模式 | 事件体系 | ArticleMsgEvent、ConfigRefreshEvent |
| 装饰器模式 | 缓存双层 | Caffeine + Redis 双层包装 |
| 工厂模式 | 图片上传 | ImageUploader 接口，AliOssWrapper/LocalStorageWrapper |
| 代理模式 | AOP切面 | 权限、数据源、异步、敏感词等切面 |
| 单例模式 | Spring Bean | 所有 Service 默认单例 |

---

## 九、项目工程化类面试题

### Q16：数据库版本管理是如何实现的？

**参考答案**：

使用 Liquibase 管理数据库版本：

1. `master.xml` 作为入口，引入所有 changeSet
2. `changelog/000_initial_schema.xml` 定义初始表结构
3. `data/` 目录下按日期组织 schema 变更和初始数据 SQL
4. 启动时自动执行未应用的 changeSet

优势：
- 团队协作时避免 SQL 冲突
- 可追溯每次数据库变更
- 支持回滚
- 新环境一键初始化

---

### Q17：多环境配置是如何管理的？

**参考答案**：

通过 Maven Profile + 环境目录实现：

1. `resources-env/` 下按环境分目录：dev/test/pre/prod
2. 每个目录包含特定环境的配置文件（dal/web/ai/image/rabbitmq）
3. pom.xml 定义 Profile，通过 `-Pdev`/`-Pprod` 切换
4. Maven 构建时将对应环境的配置文件作为资源目录
5. 敏感信息通过环境变量注入（`${DB_PASSWORD}` 等）

---

### Q18：全局异常处理是如何实现的？

**参考答案**：

`GlobalExceptionHandler` 使用 `@ControllerAdvice` + `@ExceptionHandler` 统一处理异常：

1. `ForumException`：业务异常，返回对应的 Status 错误码
2. `ForumAdviceException`：全局通知异常，需要告警
3. 其他未知异常：返回统一错误响应，记录日志

异常体系：
- `ForumException`：业务异常基类
- `CacheSyncException`：缓存同步异常
- `ExceptionUtil`：异常工具类

---

## 十、综合设计类面试题

### Q19：如果让你重新设计这个项目，你会做哪些改进？

**参考答案**：

1. **API 版本化**：当前 API 没有版本管理，后续迭代可能破坏兼容性
2. **限流机制**：缺少接口限流，高并发下可能被打崩
3. **分布式事务**：当前跨表操作没有事务保证，可引入 Seata
4. **链路追踪**：缺少分布式链路追踪，可引入 SkyWalking/Zipkin
5. **CI/CD 完善**：后端缺少自动化流水线，可引入 Jenkins/GitHub Actions
6. **容器化完善**：Docker Compose 未包含中间件，可补充完整编排
7. **监控告警**：缺少 Prometheus + Grafana 监控体系
8. **灰度发布**：缺少灰度发布能力

---

### Q20：项目中你觉得最有技术含量的设计是什么？

**参考答案**（示例）：

我认为最有技术含量的是**请求上下文 + 权限拦截**的设计：

1. `ReqInfoContext` 基于 TransmittableThreadLocal，解决了异步线程上下文传递问题
2. `ReqRecordFilter` 在请求入口初始化上下文，识别登录用户
3. `GlobalViewInterceptor` 基于 @Permission 注解做声明式权限控制
4. 整个链路：Filter 初始化 → Interceptor 校验 → Controller 处理 → 异常兜底

这种设计将认证、授权、上下文管理解耦，每个组件职责单一，易于扩展和维护。

---

## 附：面试高频知识点速查表

| 知识点 | 项目中的体现 |
|--------|-------------|
| 分层架构 | api → core → service → web |
| 多数据源 | AbstractRoutingDataSource + @DS |
| 双层缓存 | Caffeine + Redis |
| JWT认证 | Cookie/Authorization + ReqInfoContext |
| 声明式权限 | @Permission 注解 + 拦截器 |
| 策略模式 | 在线统计、AI模型选择 |
| 消息队列 | RabbitMQ 异步通知/活跃度 |
| WebSocket | STOMP + SockJS AI聊天 |
| 数据库版本 | Liquibase |
| 敏感词 | sensitive-word + MyBatis拦截器 |
| 冷热分离 | article / article_detail 拆表 |
| 多态设计 | user_foot 的 document_id + document_type |
| 环境隔离 | Maven Profile + resources-env |
| 全局异常 | @ControllerAdvice + @ExceptionHandler |
| 雪花算法 | SnowflakeProducer ID生成 |
