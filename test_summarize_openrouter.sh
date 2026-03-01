#!/bin/bash
# 测试 summarize 使用 OpenRouter API

set -e

echo "🧪 测试 summarize 使用 OpenRouter API"
echo "====================================="

# 设置环境变量
export OPENROUTER_API_KEY="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"
export OPENAI_API_KEY="$OPENROUTER_API_KEY"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"

echo "🔑 API 密钥已设置"
echo "📡 使用 OpenRouter 端点: $OPENAI_BASE_URL"

# 创建配置文件
CONFIG_DIR="$HOME/.summarize"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.json" << EOF
{
  "model": "openrouter/openai/gpt-4o-mini",
  "openai": {
    "apiKey": "$OPENROUTER_API_KEY",
    "baseURL": "https://openrouter.ai/api/v1"
  }
}
EOF

echo "✅ 配置文件已创建: $CONFIG_DIR/config.json"

# 测试1：检查 OpenRouter 连接
echo ""
echo "🔍 测试1：检查 OpenRouter 连接..."
curl -s -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  https://openrouter.ai/api/v1/models 2>/dev/null | \
  jq -r '.data[0].id' 2>/dev/null || echo "⚠️ 无法解析响应，但连接可能正常"

# 测试2：使用 summarize 测试简单网页
echo ""
echo "🔍 测试2：测试 summarize 基本功能..."
TEST_URL="https://en.wikipedia.org/wiki/Artificial_intelligence"
echo "测试 URL: $TEST_URL"
echo "模型: openrouter/openai/gpt-4o-mini"

# 运行 summarize
echo ""
echo "📝 开始总结..."
npx @steipete/summarize "$TEST_URL" \
  --model openrouter/openai/gpt-4o-mini \
  --length short \
  --max-output-tokens 200 2>&1

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "🎉 测试成功！summarize 工作正常"
else
    echo "❌ 测试失败，退出码: $EXIT_CODE"
    echo "可能的原因："
    echo "  1. API 密钥无效或过期"
    echo "  2. 网络连接问题"
    echo "  3. OpenRouter 服务异常"
    echo "  4. 模型不可用"
fi

# 测试3：使用不同的模型
echo ""
echo "🔍 测试3：测试其他模型..."
echo "模型: openrouter/anthropic/claude-3-haiku"

npx @steipete/summarize "$TEST_URL" \
  --model openrouter/anthropic/claude-3-haiku \
  --length short \
  --max-output-tokens 150 2>&1 | head -10

# 显示配置信息
echo ""
echo "📋 配置信息："
echo "• OpenRouter API 密钥: ${OPENROUTER_API_KEY:0:15}..."
echo "• 配置文件: $CONFIG_DIR/config.json"
echo "• 默认模型: openrouter/openai/gpt-4o-mini"
echo "• 可用模型:"
echo "  - openrouter/openai/gpt-4o-mini (推荐)"
echo "  - openrouter/openai/gpt-4o"
echo "  - openrouter/anthropic/claude-3-haiku"
echo "  - openrouter/anthropic/claude-3.5-sonnet"
echo "  - openrouter/google/gemini-2.0-flash-exp"

echo ""
echo "✅ 测试完成"