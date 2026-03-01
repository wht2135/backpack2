#!/bin/bash
# 自动备份到 GitHub

set -e

echo "🚀 开始 GitHub 备份 $(date '+%Y-%m-%d %H:%M:%S')"

cd /root/.openclaw/workspace

# 检查 Git 配置
if [ ! -d .git ]; then
    echo "❌ Git 仓库未初始化"
    exit 1
fi

# 检查远程仓库
if ! git remote | grep -q origin; then
    echo "❌ 未配置远程仓库"
    echo "请运行: git remote add origin <仓库URL>"
    exit 1
fi

# 获取远程仓库URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
echo "📦 远程仓库: $REMOTE_URL"

# 拉取最新更改（避免冲突）
echo "📥 拉取最新更改..."
git fetch origin

# 尝试合并，如果有冲突则跳过
if git merge origin/master --no-edit 2>/dev/null; then
    echo "✅ 成功合并远程更改"
else
    echo "⚠️  合并有冲突，跳过合并"
    git merge --abort 2>/dev/null || true
fi

# 添加更改
echo "📝 添加更改..."
git add .

# 检查是否有更改
if git diff --cached --quiet; then
    echo "✅ 没有需要提交的更改"
    exit 0
fi

# 提交更改
COMMIT_MSG="Backup: $(date '+%Y-%m-%d %H:%M:%S') - $(hostname)"
echo "💾 提交更改: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# 推送到 GitHub
echo "🚀 推送到 GitHub..."
if git push origin master; then
    echo "✅ 推送成功"
else
    echo "❌ 推送失败，尝试强制推送..."
    if git push -f origin master; then
        echo "✅ 强制推送成功"
    else
        echo "❌ 推送完全失败"
        exit 1
    fi
fi

# 记录日志
LOG_FILE="/root/.openclaw/workspace/logs/backup.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date '+%Y-%m-%d %H:%M:%S'): GitHub backup completed" >> "$LOG_FILE"

echo "✅ 备份完成 $(date '+%Y-%m-%d %H:%M:%S')"