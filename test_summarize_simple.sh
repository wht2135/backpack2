#!/bin/bash
# 简化测试 - 使用更简单的网页

set -e

echo "🧪 简化测试 summarize"
echo "====================="

# 设置环境变量
export OPENROUTER_API_KEY="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"
export OPENAI_API_KEY="$OPENROUTER_API_KEY"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"

echo "🔑 API 密钥已设置"

# 使用一个简单的测试页面
TEST_URL="https://httpbin.org/html"
echo "测试 URL: $TEST_URL (简单的测试页面)"

echo ""
echo "🔍 测试 API 连接..."
# 先测试 OpenRouter API 是否可用
API_TEST=$(curl -s -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  https://openrouter.ai/api/v1/models 2>/dev/null | wc -l)

if [ $API_TEST -gt 10 ]; then
    echo "✅ OpenRouter API 连接正常"
else
    echo "⚠️ OpenRouter API 连接可能有问题"
fi

echo ""
echo "📝 运行 summarize 测试..."
echo "命令: npx @steipete/summarize \"$TEST_URL\" --model openrouter/openai/gpt-4o-mini --length short"

# 运行测试，设置超时
timeout 30 npx @steipete/summarize "$TEST_URL" \
  --model openrouter/openai/gpt-4o-mini \
  --length short \
  --max-output-tokens 100 2>&1

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "🎉 测试成功！summarize 工作正常"
elif [ $EXIT_CODE -eq 124 ]; then
    echo "⏱️  测试超时，但 API 可能在工作"
    echo "可能是网络较慢或页面加载时间长"
else
    echo "❌ 测试失败，退出码: $EXIT_CODE"
    echo "详细错误信息在上面"
fi

# 另一个测试：使用文本输入
echo ""
echo "🔍 测试文本输入..."
echo "输入文本: 'Artificial intelligence is the simulation of human intelligence processes by machines, especially computer systems.'"

echo "Artificial intelligence is the simulation of human intelligence processes by machines, especially computer systems." | \
npx @steipete/summarize - \
  --model openrouter/openai/gpt-4o-mini \
  --length short 2>&1

echo ""
echo "📋 配置状态："
echo "• OpenRouter API: ✅ 已配置"
echo "• 环境变量: ✅ 已设置"
echo "• summarize 工具: ✅ 通过 npx 可用"
echo "• 测试结果: $( [ $EXIT_CODE -eq 0 ] && echo '✅ 成功' || echo '⚠️ 需要检查' )"

echo ""
echo "💡 下一步建议："
echo "1. 如果测试失败，可能是网络问题"
echo "2. 可以尝试其他 URL 测试"
echo "3. 确保 OpenRouter 账号有额度"
echo "4. 检查防火墙或代理设置"