#!/bin/bash
# 小方字典 - 一键部署到 GitHub 并触发云端构建
# 使用方法：./deploy-to-github.sh

set -e

echo "======================================"
echo "  小方字典 - 一键部署到 GitHub"
echo "======================================"
echo ""

# 检查 git 是否安装
if ! command -v git &> /dev/null; then
    echo "❌ 错误：git 未安装"
    echo "请先安装 git: brew install git"
    exit 1
fi

# 检查是否在 git 仓库中
if [ ! -d ".git" ]; then
    echo "📦 初始化 git 仓库..."
    git init
fi

# 获取 GitHub 用户名
echo ""
echo "请输入你的 GitHub 用户名:"
read -p "> " GITHUB_USERNAME

# 获取仓库名（默认 xiaofang-dict）
echo ""
echo "请输入仓库名 (默认：xiaofang-dict):"
read -p "> " REPO_NAME
REPO_NAME=${REPO_NAME:-xiaofang-dict}

# 设置远程仓库
REMOTE_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

echo ""
echo "📋 配置信息:"
echo "   GitHub 用户名：${GITHUB_USERNAME}"
echo "   仓库名：${REPO_NAME}"
echo "   远程地址：${REMOTE_URL}"
echo ""

# 检查远程仓库是否存在
if git remote get-url origin &> /dev/null; then
    echo "⚠️  远程仓库已存在，是否覆盖？(y/N)"
    read -p "> " OVERWRITE
    if [[ $OVERWRITE != "y" && $OVERWRITE != "Y" ]]; then
        echo "取消部署"
        exit 0
    fi
fi

# 添加所有文件
echo "📦 添加项目文件..."
git add .

# 提交
echo "💾 提交更改..."
git commit -m "Initial commit - 小方字典 v1.0.0" || echo "（没有新更改）"

# 设置分支名
git branch -M main 2>/dev/null || true

# 设置远程仓库
echo "🔗 设置远程仓库..."
git remote remove origin 2>/dev/null || true
git remote add origin $REMOTE_URL

# 推送
echo ""
echo "======================================"
echo "  🚀 推送到 GitHub..."
echo "======================================"
echo ""
echo "⚠️  首次推送需要输入 GitHub 账号密码"
echo "   或使用 Personal Access Token"
echo ""

git push -u origin main

echo ""
echo "======================================"
echo "  ✅ 部署成功！"
echo "======================================"
echo ""
echo "📱 下一步操作："
echo ""
echo "1. 访问你的 GitHub 仓库:"
echo "   https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo ""
echo "2. 点击 'Actions' 标签查看构建进度"
echo ""
echo "3. 构建完成后（约 15 分钟），在 Artifacts 下载安装包"
echo ""
echo "📖 详细说明请查看：CLOUD_BUILD.md"
echo ""
