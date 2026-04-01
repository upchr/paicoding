#!/bin/bash

# 技术派后端 Docker 打包脚本
# 使用说明: 在项目根目录执行: docker/build.sh [env]

cd "$(dirname "$0")/.." || exit 1

echo "========================================"
echo "开始构建技术派后端 Docker 镜像"
echo "========================================"

# 检查是否安装了 Maven
if ! command -v mvn &> /dev/null; then
    echo "错误: 未检测到 Maven，请先安装 Maven"
    exit 1
fi

# 检查是否安装了 Docker
if ! command -v docker &> /dev/null; then
    echo "错误: 未检测到 Docker，请先安装 Docker"
    exit 1
fi

# 设置环境变量（可根据需要修改）
ENV=${1:-prod}
echo "构建环境: $ENV"

# 清理并打包
echo "========================================"
echo "步骤 1: Maven 打包"
echo "========================================"
mvn clean package -DskipTests -P$ENV

if [ $? -ne 0 ]; then
    echo "错误: Maven 打包失败"
    exit 1
fi

echo "Maven 打包成功！"

# 检查 jar 文件是否存在
JAR_FILE="paicoding-web/target/paicoding-web-0.0.1-SNAPSHOT.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "错误: 找不到打包后的 jar 文件: $JAR_FILE"
    exit 1
fi

echo "找到 jar 文件: $JAR_FILE"

# 构建 Docker 镜像
echo "========================================"
echo "步骤 2: 构建 Docker 镜像"
echo "========================================"
docker build -f docker/Dockerfile -t paicoding-backend:latest .

if [ $? -ne 0 ]; then
    echo "错误: Docker 镜像构建失败"
    exit 1
fi

echo "Docker 镜像构建成功！"

# 显示镜像信息
echo "========================================"
echo "镜像信息"
echo "========================================"
docker images | grep paicoding-backend

echo ""
echo "========================================"
echo "构建完成！"
echo "========================================"
echo ""
echo "启动命令："
echo "  docker run -d -p 8081:8081 --name paicoding-backend paicoding-backend:latest"
echo ""
echo "或者使用 docker-compose："
echo "  cd docker && docker-compose up -d"
echo ""
echo "停止命令："
echo "  docker stop paicoding-backend"
echo "  docker rm paicoding-backend"
echo ""
echo "查看日志："
echo "  docker logs -f paicoding-backend"