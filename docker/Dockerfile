# 使用 Eclipse Temurin 17 作为基础镜像（Alpine 版本更轻量）
FROM eclipse-temurin:17-jdk-alpine

# 设置工作目录
WORKDIR /app

# 复制打包后的 jar 文件（从构建上下文的根目录）
COPY paicoding-web/target/paicoding-web-0.0.1-SNAPSHOT.jar app.jar

# 复制外部配置文件（从构建上下文的 docker/config 目录）
COPY docker/config /app/config

# 创建必要的目录
RUN mkdir -p /app/logs /app/data/upload

# 设置时区（Alpine 需要安装 tzdata）
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    apk del tzdata

# 暴露端口
EXPOSE 8081

# JVM 参数优化
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动应用 - 使用外部配置文件
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-Dspring.config.location=classpath:/,file:/app/config/", "-jar", "app.jar"]