#!/bin/bash
# GitHub 备份配置脚本
# 需要先创建 GitHub 仓库

set -e

echo "🚀 GitHub 备份配置向导"
echo "======================"

# 检查 Git
if ! command -v git > /dev/null; then
    echo "❌ Git 未安装"
    echo "请先安装 Git: apt-get install git 或 yum install git"
    exit 1
fi

# 检查当前目录
cd /root/.openclaw/workspace

# 1. 检查是否已初始化
if [ ! -d .git ]; then
    echo "📦 初始化 Git 仓库..."
    git init
    echo "✅ Git 仓库初始化完成"
else
    echo "✅ Git 仓库已初始化"
fi

# 2. 配置用户信息
echo ""
echo "👤 配置 Git 用户信息:"
read -p "请输入 GitHub 邮箱: " GIT_EMAIL
read -p "请输入 GitHub 用户名: " GIT_NAME

if [ -n "$GIT_EMAIL" ] && [ -n "$GIT_NAME" ]; then
    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_NAME"
    echo "✅ Git 用户信息已配置"
else
    echo "⚠️  未输入用户信息，使用默认配置"
    git config user.email "openclaw@$(hostname)"
    git config user.name "OpenClaw Backup"
fi

# 3. 配置远程仓库
echo ""
echo "🌐 配置远程仓库:"
echo "请先在 GitHub 上创建仓库，然后提供仓库URL"
echo "格式: https://github.com/用户名/仓库名.git"
read -p "GitHub 仓库URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "❌ 未提供仓库URL，跳过远程配置"
    echo "您可以稍后手动运行: git remote add origin <URL>"
    REMOTE_CONFIGURED=false
else
    # 检查是否已配置远程仓库
    if git remote | grep -q origin; then
        echo "🔄 更新远程仓库URL..."
        git remote set-url origin "$REPO_URL"
    else
        echo "➕ 添加远程仓库..."
        git remote add origin "$REPO_URL"
    fi
    echo "✅ 远程仓库已配置: $REPO_URL"
    REMOTE_CONFIGURED=true
fi

# 4. 创建 .gitignore
echo ""
echo "📄 创建 .gitignore 文件..."
cat > .gitignore << 'EOF'
# 敏感文件
*.key
*.pem
*.env
.secrets/
.secret/
config.json
credentials*

# 缓存和日志
cache/
logs/
*.log
*.tmp
*.temp
*.cache

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# 系统文件
.openclaw/
.clawhub/
.learnings/

# 编辑器文件
.vscode/
.idea/
*.swp
*.swo

# 技能目录（可通过clawhub重新安装）
skills/*

# 备份文件
*.backup
*.old
EOF
echo "✅ .gitignore 文件已创建"

# 5. 首次提交
echo ""
echo "💾 执行首次提交..."
git add .
if git diff --cached --quiet; then
    echo "ℹ️  没有需要提交的更改"
else
    git commit -m "Initial commit: OpenClaw workspace backup - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "✅ 首次提交完成"
    
    # 6. 推送到远程（如果配置了）
    if [ "$REMOTE_CONFIGURED" = true ]; then
        echo ""
        echo "🚀 推送到 GitHub..."
        if git push -u origin master; then
            echo "✅ 首次推送成功"
        else
            echo "⚠️  首次推送失败，可能需要设置SSH密钥或使用token"
            echo "提示: 可以使用 HTTPS 方式，需要输入用户名和密码"
            echo "或者配置 SSH 密钥: https://docs.github.com/authentication"
        fi
    fi
fi

# 7. 创建备份脚本
echo ""
echo "📜 创建自动备份脚本..."
cat > backup_to_github.sh << 'EOF'
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

# 拉取最新更改（避免冲突）
echo "📥 拉取最新更改..."
if git remote | grep -q origin; then
    git fetch origin
    git merge origin/master --no-edit || true
else
    echo "⚠️  未配置远程仓库，跳过拉取"
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

# 推送到 GitHub（如果配置了远程仓库）
if git remote | grep -q origin; then
    echo "🚀 推送到 GitHub..."
    git push origin master
    echo "✅ 推送完成"
else
    echo "ℹ️  未配置远程仓库，更改已提交到本地仓库"
fi

# 记录日志
echo "$(date '+%Y-%m-%d %H:%M:%S'): GitHub backup completed" >> /root/.openclaw/workspace/logs/backup.log

echo "✅ 备份完成 $(date '+%Y-%m-%d %H:%M:%S')"
EOF

chmod +x backup_to_github.sh
echo "✅ 备份脚本已创建: backup_to_github.sh"

# 8. 设置定时备份
echo ""
echo "⏰ 设置定时备份..."
read -p "是否设置每日自动备份？(y/n): " SETUP_CRON

if [[ "$SETUP_CRON" =~ ^[Yy]$ ]]; then
    (crontab -l 2>/dev/null; echo "# GitHub 每日备份（凌晨2点）"; echo "0 2 * * * /root/.openclaw/workspace/backup_to_github.sh >> /root/.openclaw/workspace/logs/cron_backup.log 2>&1") | crontab -
    echo "✅ 已添加每日备份定时任务（凌晨2点）"
    
    # 也可以设置每小时备份（可选）
    read -p "是否也设置每小时备份？（更频繁但可能占用更多资源）(y/n): " HOURLY_BACKUP
    if [[ "$HOURLY_BACKUP" =~ ^[Yy]$ ]]; then
        (crontab -l 2>/dev/null; echo "# GitHub 每小时备份"; echo "0 * * * * /root/.openclaw/workspace/backup_to_github.sh >> /root/.openclaw/workspace/logs/cron_backup_hourly.log 2>&1") | crontab -
        echo "✅ 已添加每小时备份定时任务"
    fi
else
    echo "ℹ️  跳过定时备份设置，可以稍后手动添加"
fi

# 9. 创建手动备份命令
echo ""
echo "🔧 创建手动备份命令..."
cat > /usr/local/bin/backup-openclaw << 'EOF'
#!/bin/bash
cd /root/.openclaw/workspace && ./backup_to_github.sh
EOF
chmod +x /usr/local/bin/backup-openclaw
echo "✅ 创建手动备份命令: backup-openclaw"

# 10. 总结
echo ""
echo "🎉 GitHub 备份配置完成！"
echo ""
echo "📋 配置摘要:"
echo "   1. Git 仓库: ✅ 已初始化"
echo "   2. 用户信息: ✅ 已配置"
if [ "$REMOTE_CONFIGURED" = true ]; then
    echo "   3. 远程仓库: ✅ 已配置 ($REPO_URL)"
else
    echo "   3. 远程仓库: ❌ 未配置（需要手动配置）"
fi
echo "   4. .gitignore: ✅ 已创建"
echo "   5. 备份脚本: ✅ 已创建 (backup_to_github.sh)"
echo "   6. 定时任务: ✅ 已配置（如果选择）"
echo "   7. 手动命令: ✅ 已创建 (backup-openclaw)"
echo ""
echo "🚀 使用说明:"
echo "   1. 手动备份: backup-openclaw"
echo "   2. 查看状态: git status"
echo "   3. 查看日志: tail -f /root/.openclaw/workspace/logs/backup.log"
echo "   4. 查看定时任务: crontab -l"
echo ""
echo "💡 下一步:"
if [ "$REMOTE_CONFIGURED" = false ]; then
    echo "   1. 在 GitHub 上创建仓库"
    echo "   2. 运行: git remote add origin <仓库URL>"
    echo "   3. 运行: git push -u origin master"
fi
echo "   4. 测试备份: backup-openclaw"
echo "   5. 检查监控面板: ./monitor_dashboard.sh"

echo ""
echo "✅ 所有配置完成！"