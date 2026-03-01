#!/bin/bash
# 测试新闻总结功能

set -e

echo "📰 测试新闻总结功能"
echo "==================="

# 设置环境变量
export OPENROUTER_API_KEY="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"
export OPENAI_API_KEY="$OPENROUTER_API_KEY"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"

echo "🔑 API 密钥已设置"

# 测试一个科技新闻页面
TEST_URL="https://techcrunch.com/2024/01/15/ai-advances-2024/"
echo "测试 URL: $TEST_URL"
echo "这是一个科技新闻页面"

echo ""
echo "📝 开始总结科技新闻..."
echo "模型: openrouter/openai/gpt-4o-mini"
echo "长度: medium"

# 运行 summarize
npx @steipete/summarize "$TEST_URL" \
  --model openrouter/openai/gpt-4o-mini \
  --length medium \
  --max-output-tokens 300 2>&1

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ 新闻总结测试成功"
else
    echo "⚠️ 新闻页面可能无法访问，尝试备用测试..."
    
    # 备用测试：使用 BBC 新闻
    echo ""
    echo "🔍 尝试 BBC 新闻测试..."
    BBC_URL="https://www.bbc.com/news/technology"
    
    npx @steipete/summarize "$BBC_URL" \
      --model openrouter/openai/gpt-4o-mini \
      --length short \
      --max-output-tokens 200 2>&1 | head -20
fi

# 测试财经相关内容
echo ""
echo "💰 测试财经内容总结..."
echo "输入一段财经文本进行总结"

FINANCE_TEXT="The Federal Reserve is expected to maintain interest rates at current levels in its upcoming meeting, according to market analysts. Inflation has shown signs of moderating, but remains above the central bank's 2% target. Economic growth continues at a steady pace, with unemployment near historic lows. Investors are closely watching for any signals about future policy direction."

echo "文本: $FINANCE_TEXT"
echo ""
echo "总结结果:"

echo "$FINANCE_TEXT" | \
npx @steipete/summarize - \
  --model openrouter/openai/gpt-4o-mini \
  --length short 2>&1

echo ""
echo "🎯 针对交易者的使用示例："
echo ""
echo "1. 总结市场报告："
echo "   npx @steipete/summarize \"/path/to/market-report.pdf\" \\"
echo "     --model openrouter/anthropic/claude-3.5-sonnet \\"
echo "     --length long"
echo ""
echo "2. 快速浏览新闻："
echo "   npx @steipete/summarize \"https://news.example.com/finance\" \\"
echo "     --model openrouter/openai/gpt-4o-mini \\"
echo "     --length short"
echo ""
echo "3. 批量处理："
echo "   for url in \\"
echo "     \"https://news1.com\" \\"
echo "     \"https://news2.com\" \\"
echo "     \"https://news3.com\""
echo "   do"
echo "     npx @steipete/summarize \"\$url\" \\"
echo "       --model openrouter/openai/gpt-4o-mini \\"
echo "       --length short"
echo "     echo \"---\""
echo "   done"

echo ""
echo "✅ 测试完成 - summarize 工具配置成功！"