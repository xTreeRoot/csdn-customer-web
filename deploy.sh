#!/bin/bash

# 客户前端部署脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY="/Users/xugenyin/file/csdn-admin/test.pem"
SERVER="root@121.43.245.6"
REMOTE_DIR="/var/www/csdn-customer-web"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "========================================="
echo "客户前端部署"
echo "========================================="

cd "$SCRIPT_DIR"

# 安装依赖
log_info "安装依赖..."
pnpm install

# 构建项目
log_info "构建项目..."
pnpm build

if [ $? -ne 0 ]; then
    log_error "构建失败"
    exit 1
fi

log_info "构建成功"

# 上传文件到服务器
log_info "上传文件到服务器..."
rsync -avz --delete -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
    dist/ $SERVER:$REMOTE_DIR/

if [ $? -ne 0 ]; then
    log_error "上传失败"
    exit 1
fi

log_info "上传成功"

# 重启Nginx
log_info "重启Nginx..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SERVER" "systemctl restart nginx"

if [ $? -eq 0 ]; then
    log_info "Nginx重启成功"
else
    log_error "Nginx重启失败"
    exit 1
fi

log_info "========================================="
log_info "部署完成！"
log_info "访问地址: http://121.43.245.6/customer"
log_info "========================================="