#!/bin/bash
# Tavily API 快速测试脚本

echo "🚀 Tavily API 快速测试"
echo "====================="

# 检查环境变量
if [ -z "$TAVILY_API_KEY" ]; then
    echo "❌ TAVILY_API_KEY 未设置"
    echo ""
    echo "请先设置环境变量："
    echo "export TAVILY_API_KEY=\"tvly-xxxxxxxxxxxxxxxxxxxxxxxx\""
    echo ""
    echo "或运行配置脚本："
    echo "/root/.openclaw/workspace/configure_tavily.sh"
    exit 1
fi

echo "✅ API 密钥已设置（前10位: ${TAVILY_API_KEY:0:10}...）"

# 进入技能目录
cd /root/.openclaw/workspace/skills/tavily-search

# 测试1：简单搜索
echo ""
echo "🔍 测试1：简单搜索"
echo "搜索词: 'AI advancements'"
node scripts/search.mjs "AI advancements" -n 2 2>&1 | head -30

# 测试2：新闻搜索
echo ""
echo "📰 测试2：新闻搜索"
echo "搜索词: 'technology news'"
node scripts/search.mjs "technology news" --topic news -n 2 2>&1 | head -30

# 测试3：深度搜索
echo ""
echo "🔬 测试3：深度搜索"
echo "搜索词: 'machine learning'"
node scripts/search.mjs "machine learning" --deep -n 1 2>&1 | head -30

# 显示配置信息
echo ""
echo "📋 配置信息："
echo "• API 密钥状态: ✅ 已配置"
echo "• 技能位置: $(pwd)"
echo "• 测试时间: $(date)"
echo "• 下次使用: 直接运行 node scripts/search.mjs \"查询词\""

echo ""
echo "✅ 测试完成！如果看到搜索结果，说明配置成功。"