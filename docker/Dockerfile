# 使用 Eclipse Temurin 17 Debian（支持 ARM64，兼容性最佳）
# 镜像大小约 500MB，但更稳定
FROM eclipse-temurin:17-jdk

# 设置工作目录
WORKDIR /app

# 复制打包后的 jar 文件
COPY paicoding-web/target/paicoding-web-0.0.1-SNAPSHOT.jar app.jar

# 创建必要的目录
RUN mkdir -p /app/logs /app/data/upload

# 设置时区（Debian 内置 tzdata，无需安装）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# 暴露端口
EXPOSE 8081

# JVM 参数优化
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动应用
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]
