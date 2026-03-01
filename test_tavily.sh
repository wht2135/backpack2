#!/bin/bash
# Tavily Search 测试脚本

echo "🧪 Tavily Search 测试脚本"
echo "========================"

# 检查技能目录
if [ ! -d "/root/.openclaw/workspace/skills/tavily-search" ]; then
    echo "❌ Tavily Search 技能未安装"
    exit 1
fi

echo "✅ 技能目录存在"

# 检查脚本文件
cd /root/.openclaw/workspace/skills/tavily-search

if [ ! -f "scripts/search.mjs" ]; then
    echo "❌ 搜索脚本不存在"
    exit 1
fi

if [ ! -f "scripts/extract.mjs" ]; then
    echo "❌ 提取脚本不存在"
    exit 1
fi

echo "✅ 脚本文件完整"

# 检查环境变量
if [ -z "$TAVILY_API_KEY" ]; then
    echo "❌ TAVILY_API_KEY 未设置"
    echo ""
    echo "请先设置环境变量："
    echo "  export TAVILY_API_KEY=\"your_api_key_here\""
    echo ""
    echo "或运行配置脚本："
    echo "  ./configure_tavily.sh"
    exit 1
fi

echo "✅ TAVILY_API_KEY 已设置（前10位: ${TAVILY_API_KEY:0:10}...）"

# 测试搜索功能
echo ""
echo "🔍 测试搜索功能..."
echo "搜索词: 'AI assistant'"

# 运行搜索（限制1个结果，避免过多消耗）
node scripts/search.mjs "AI assistant" -n 1 2>&1

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo ""
    echo "🎉 测试成功！Tavily Search 工作正常"
    echo ""
    echo "📊 可用命令："
    echo "  node scripts/search.mjs \"查询词\""
    echo "  node scripts/search.mjs \"查询词\" -n 10"
    echo "  node scripts/search.mjs \"查询词\" --deep"
    echo "  node scripts/search.mjs \"查询词\" --topic news"
else
    echo ""
    echo "❌ 测试失败，退出码: $exit_code"
    echo ""
    echo "🔧 故障排除："
    echo "1. 检查 API 密钥是否正确"
    echo "2. 检查网络连接"
    echo "3. 检查 Tavily 账号额度"
    echo "4. 查看详细错误信息"
fi