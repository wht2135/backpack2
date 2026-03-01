#!/bin/bash
# Tavily Search 技能配置脚本

echo "🔧 Tavily Search 技能配置脚本"
echo "=============================="

# 检查是否已安装技能
if [ ! -d "/root/.openclaw/workspace/skills/tavily-search" ]; then
    echo "❌ Tavily Search 技能未安装"
    exit 1
fi

echo "✅ Tavily Search 技能已安装"

# 检查环境变量
if [ -z "$TAVILY_API_KEY" ]; then
    echo "⚠️  TAVILY_API_KEY 未设置"
    echo ""
    echo "📋 请按以下步骤获取 API 密钥："
    echo "1. 访问 https://tavily.com"
    echo "2. 注册账号并登录"
    echo "3. 在 Dashboard 中生成 API 密钥"
    echo "4. 将密钥粘贴到下方："
    echo ""
    read -p "请输入 Tavily API 密钥: " api_key
    
    if [ -n "$api_key" ]; then
        # 设置环境变量
        export TAVILY_API_KEY="$api_key"
        echo "✅ 环境变量已设置（当前会话有效）"
        
        # 可选：保存到文件
        read -p "是否保存到配置文件？(y/n): " save_choice
        if [[ "$save_choice" =~ ^[Yy]$ ]]; then
            echo "export TAVILY_API_KEY=\"$api_key\"" >> ~/.bashrc
            echo "✅ 已添加到 ~/.bashrc"
            echo "请运行 'source ~/.bashrc' 或重新打开终端"
        fi
    else
        echo "❌ 未输入 API 密钥"
        exit 1
    fi
else
    echo "✅ TAVILY_API_KEY 已设置"
fi

# 测试技能
echo ""
echo "🧪 测试 Tavily Search 技能..."
cd /root/.openclaw/workspace/skills/tavily-search

# 简单测试
echo "测试搜索 'OpenClaw AI'..."
node scripts/search.mjs "OpenClaw AI" -n 3

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 配置成功！Tavily Search 技能已就绪"
    echo ""
    echo "📚 使用示例："
    echo "  node scripts/search.mjs \"查询词\""
    echo "  node scripts/search.mjs \"查询词\" -n 10"
    echo "  node scripts/search.mjs \"查询词\" --deep"
    echo "  node scripts/search.mjs \"查询词\" --topic news"
else
    echo ""
    echo "❌ 测试失败，请检查："
    echo "  1. API 密钥是否正确"
    echo "  2. 网络连接是否正常"
    echo "  3. Tavily 账号是否有额度"
fi