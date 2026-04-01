# iFlow 项目上下文文档

## 项目概述

**技术派（paicoding）** - 一个基于主流技术栈实现的现代化社区系统，采用前后端分离架构。

### 核心技术栈

**后端：**
- Spring Boot 3.0.9 + Spring MVC
- MyBatis-Plus 3.5.4（数据库 ORM）
- MySQL 8.0+、Redis、ElasticSearch、MongoDB
- RabbitMQ（消息队列）
- JWT（身份认证）
- Liquibase（数据库版本管理）
- Knife4j 4.5.0（API 文档）
- JDK 17+、Maven 3.5+

**前端：**
- Vue 3.4.21 + TypeScript 5.4.0
- Vite 5.2.8（构建工具）
- Element Plus 2.7.5（UI 组件库）
- Pinia 2.1.7（状态管理）
- Vue Router 4.3.0（路由管理）
- Axios 1.7.2（HTTP 客户端）
- Tailwind CSS 3.4.4（样式框架）

## 项目结构

```
paicoding/
├── pai-coding-front/          # Vue3 前端模块
│   ├── src/
│   │   ├── views/             # 页面组件
│   │   ├── components/        # 公共组件
│   │   ├── router/            # 路由配置
│   │   ├── stores/            # Pinia 状态管理
│   │   ├── http/              # HTTP 请求封装
│   │   ├── constants/         # 常量定义
│   │   └── assets/            # 静态资源
│   ├── package.json
│   └── vite.config.ts
├── paicoding-api/             # API 模块（枚举、实体类、DTO/VO）
├── paicoding-core/            # 核心工具/组件模块
├── paicoding-service/         # 业务服务模块（数据库操作）
├── paicoding-web/             # Web 模块（HTTP 入口、启动入口）
│   ├── src/main/java/
│   │   └── com/github/paicoding/forum/web/
│   │       ├── QuickForumApplication.java  # 启动类
│   │       ├── controller/    # 控制器
│   │       ├── config/        # 配置类
│   │       ├── global/        # 全局异常处理等
│   │       └── hook/          # 拦截器
│   └── src/main/resources/
│       ├── application.yml    # 主配置文件
│       ├── liquibase/         # 数据库版本管理
│       └── resources-env/     # 环境配置（dev/test/pre/prod）
└── pom.xml                    # Maven 父 POM
```

## 构建和运行

### 后端

**启动类：** `com.github.paicoding.forum.web.QuickForumApplication`

**默认端口：** 8081

**环境切换：**
```bash
# 开发环境（默认）
mvn clean install -DskipTests=true

# 测试环境
mvn clean install -DskipTests=true -Ptest

# 预发环境
mvn clean install -DskipTests=true -Ppre

# 生产环境
mvn clean install -DskipTests=true -Pprod
```

**配置文件位置：**
- 主配置：`paicoding-web/src/main/resources/application.yml`
- 环境配置：`paicoding-web/src/main/resources/resources-env/{env}/`

**数据库配置：**
- 默认数据库名：`pai_coding`
- 自动创建表：项目启动时会自动创建数据库和表结构（通过 Liquibase）
- 配置位置：`paicoding-web/src/main/resources/application.yml` 中的 `database.name`

**启动方式：**
1. 在 IDEA 中直接运行 `QuickForumApplication`
2. 使用 Maven 命令：`mvn spring-boot:run -pl paicoding-web`

### 前端

**进入前端目录：**
```bash
cd pai-coding-front
```

**安装依赖：**
```bash
npm install
```

**开发模式：**
```bash
npm run dev
```

**生产构建：**
```bash
npm run build
```

**类型检查：**
```bash
npm run type-check
```

**代码格式化：**
```bash
npm run format
```

**后端 API 地址配置：**
- 配置文件：`pai-coding-front/src/http/URL.ts`
- 默认地址：`http://localhost:8081`
- WebSocket 地址：`ws://localhost:8081`

## 开发约定

### 后端规范

**Controller 层：**
- **RestController**：返回 JSON/XML/String 数据
  - 路径：`业务/api/xxx`
  - 包位置：`rest` 包路径下
- **ViewController**：返回视图
  - 路径：`业务/view/xxx` 或 `业务/xxx`
  - 包位置：`view` 包路径下

**DAO 层方法命名：**
- `getXxx`：查询单条记录
- `listXxx`：查询多条记录
- `selectXxxByXxx`：根据条件查询（类 JPA 用法）
- `updateXxx`：更新数据
- `removeXxx`：删除数据

**Service 层方法命名：**
- 优先使用 `queryXxx`、`findXxx`
- 避免使用 `getXxx`、`selectXxx`

**接口拆分原则：**
- 按业务拆分
- 按读写拆分
- 按版本拆分（多版本管理时）

### 前端规范

**HTTP 请求：**
- 使用 `BackendRequests.ts` 中的封装方法
- 所有新功能使用 `window.$request` 进行请求（已统一封装异常处理，可直接返回 data）

**请求方法：**
- `doGet<CommonResponse>(url, params, type?)`
- `doPost<CommonResponse>(url, data)`
- `doFilePost<T>(url, data)` - 文件上传
- `doPut<T>(url, data)`
- `doDelete<T>(url, params)`

**路由配置：**
- 配置文件：`pai-coding-front/src/router/index.ts`
- 使用 Vue Router 4 的 history 模式
- 支持路由守卫进行登录验证

**状态管理：**
- 使用 Pinia 进行状态管理
- 全局状态存储在 `stores/global.ts`

**组件规范：**
- 页面组件放在 `views/` 目录
- 公共组件放在 `components/` 目录
- 使用 TypeScript 进行类型定义

## 重要配置

### 后端配置文件

**application.yml 关键配置：**
```yaml
server:
  port: 8081

spring:
  liquibase:
    enabled: true
    clear-checksums: true  # 开发环境清除 checksums

mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true  # 下划线转驼峰

paicoding:
  jwt:
    issuer: pai_coding
    secret: hello_world
    expire: 2592000000  # 30天
```

### 前端配置文件

**vite.config.ts：**
- 使用 `@` 别名指向 `src` 目录
- 配置了 Vue DevTools 插件

**package.json 脚本：**
- `dev`：启动开发服务器
- `build`：构建生产版本
- `type-check`：类型检查
- `lint`：代码检查和修复
- `format`：代码格式化

## API 文档

**Knife4j 访问地址：**
- UI 界面：`http://localhost:8081/swagger-ui.html`
- 认证信息：
  - 用户名：root
  - 密码：123456

**API 分组：**
- **前台接口分组**：`com.github.paicoding.forum.web.front`
- **后台接口分组**：`com.github.paicoding.forum.web.admin`

## 测试

**后端测试：**
- 单元测试：使用 JUnit
- 集成测试：使用 Spock（Groovy）
- 性能测试：使用 JMH
- 测试命令：`mvn test`

**前端测试：**
- 类型检查：`npm run type-check`
- 代码检查：`npm run lint`

## 注意事项

1. **数据库自动创建**：项目启动时会自动创建数据库和表，无需手动执行 SQL
2. **端口冲突**：开发环境下，如果 8081 端口被占用，会自动使用 8000-10000 范围内的可用端口
3. **跨域配置**：项目已配置 CORS，支持所有接口跨域访问
4. **JWT 认证**：登录后使用 JWT 进行身份验证，有效期 30 天
5. **文件上传**：支持最大 5MB 文件上传，请求最大 10MB
6. **环境切换**：通过 Maven profile 切换环境，默认使用 dev 环境

## 依赖管理

**Maven 父 POM 版本：**
- Spring Boot：3.0.9
- MyBatis-Plus：3.5.4
- Druid：1.2.20
- Knife4j：4.5.0
- MapStruct：1.4.2.Final
- Redisson：3.16.4

**NPM 依赖版本：**
- Vue：3.4.21
- TypeScript：5.4.0
- Vite：5.2.8
- Element Plus：2.7.5
- Pinia：2.1.7
- Axios：1.7.2

## 相关资源

- **项目文档**：`docs/` 目录
- **安装教程**：`docs/安装环境.md`
- **本地开发教程**：`docs/本地开发环境配置教程.md`
- **约定规范**：`docs/约定.md`
- **前端结构说明**：`docs/前端工程结构说明.md`
- **官方演示**：http://www.xuyifei.site
- **GitHub 仓库**：https://github.com/itwanger/paicoding

## 已添加的记忆

- 所有新功能使用 window.$request 进行请求，该方法已统一封装好异常处理，可以直接返回 data