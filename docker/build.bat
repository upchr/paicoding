@echo off
REM 技术派后端 Docker 打包脚本 (Windows)
REM 使用说明: 在项目根目录执行: docker\build.bat [env]

cd /d "%~dp0.."

echo ========================================
echo 开始构建技术派后端 Docker 镜像
echo ========================================

REM 检查是否安装了 Maven
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: 未检测到 Maven，请先安装 Maven
    exit /b 1
)

REM 检查是否安装了 Docker
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: 未检测到 Docker，请先安装 Docker
    exit /b 1
)

REM 设置环境变量（可根据需要修改）
set "ENV=%~1"
if "%ENV%"=="" set "ENV=prod"
echo 构建环境: %ENV%

REM 清理并打包
echo ========================================
echo 步骤 1: Maven 打包
echo ========================================
call mvn clean package -DskipTests -P%ENV%

if %errorlevel% neq 0 (
    echo 错误: Maven 打包失败
    exit /b 1
)

echo Maven 打包成功！

REM 检查 jar 文件是否存在
set "JAR_FILE=paicoding-web\target\paicoding-web-0.0.1-SNAPSHOT.jar"
if not exist "%JAR_FILE%" (
    echo 错误: 找不到打包后的 jar 文件: %JAR_FILE%
    exit /b 1
)

echo 找到 jar 文件: %JAR_FILE%

REM 构建 Docker 镜像
echo ========================================
echo 步骤 2: 构建 Docker 镜像
echo ========================================
docker build -f docker\Dockerfile -t paicoding-backend:latest .

if %errorlevel% neq 0 (
    echo 错误: Docker 镜像构建失败
    exit /b 1
)

echo Docker 镜像构建成功！

REM 显示镜像信息
echo ========================================
echo 镜像信息
echo ========================================
docker images | findstr paicoding-backend

echo.
echo ========================================
echo 构建完成！
echo ========================================
echo.
echo 启动命令：
echo   docker run -d -p 8081:8081 --name paicoding-backend paicoding-backend:latest
echo.
echo 或者使用 docker-compose：
echo   cd docker && docker-compose up -d
echo.
echo 停止命令：
echo   docker stop paicoding-backend
echo   docker rm paicoding-backend
echo.
echo 查看日志：
echo   docker logs -f paicoding-backend

pause