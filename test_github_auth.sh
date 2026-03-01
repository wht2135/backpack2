#!/bin/bash
# GitHub 认证测试脚本

echo "🔐 GitHub 认证测试"
echo "=================="

cd /root/.openclaw/workspace

# 检查远程仓库配置
echo "📋 当前远程仓库配置:"
git remote -v
echo ""

# 测试拉取（会触发认证）
echo "🔍 测试拉取远程仓库..."
if git fetch origin 2>&1 | grep -q "Authentication failed"; then
    echo "❌ 认证失败"
    echo ""
    echo "💡 认证方式建议:"
    echo "1. GitHub Personal Access Token"
    echo "   - 访问: https://github.com/settings/tokens"
    echo "   - 生成 token (权限: repo)"
    echo "   - 用户名: wht2135"
    echo "   - 密码: 使用生成的token"
    echo ""
    echo "2. 或者运行手动推送测试:"
    echo "   cd /root/.openclaw/workspace"
    echo "   git push origin master"
    echo "   # 会提示输入用户名和密码/token"
else
    echo "✅ 认证成功或不需要认证"
fi

echo ""
echo "📊 当前Git配置:"
echo "用户: $(git config user.name)"
echo "邮箱: $(git config user.email)"
echo "凭证存储: $(git config credential.helper)"

echo ""
echo "🚀 手动测试命令:"
echo "git push origin master"
echo "# 首次会提示输入认证信息"