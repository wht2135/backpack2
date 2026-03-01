#!/bin/bash
# 简化版 summarize 安装脚本

set -e

echo "🔧 简化版 summarize 安装脚本"
echo "============================="

# 方法1：使用 npx（无需安装）
echo "📦 方法1：使用 npx 直接运行"
echo "npx @steipete/summarize \"https://example.com\""

# 创建 npx 包装脚本
cat > /usr/local/bin/summarize-npx << 'EOF'
#!/bin/bash
# npx 包装脚本
npx @steipete/summarize "$@"
EOF

chmod +x /usr/local/bin/summarize-npx

echo "✅ 创建 npx 包装脚本: /usr/local/bin/summarize-npx"

# 方法2：全局安装
echo ""
echo "📦 方法2：全局安装（如果网络允许）"
echo "npm i -g @steipete/summarize"

# 方法3：使用 Docker
echo ""
echo "🐳 方法3：使用 Docker（如果有 Docker）"
cat > /usr/local/bin/summarize-docker << 'EOF'
#!/bin/bash
# Docker 包装脚本
docker run --rm -it \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  -e OPENAI_BASE_URL="$OPENAI_BASE_URL" \
  -v "$(pwd):/data" \
  ghcr.io/steipete/summarize:latest "$@"
EOF

chmod +x /usr/local/bin/summarize-docker
echo "✅ 创建 Docker 包装脚本: /usr/local/bin/summarize-docker"

# 检查 Docker 镜像
echo "Docker 镜像: ghcr.io/steipete/summarize:latest"

# OpenRouter 配置
echo ""
echo "🔑 OpenRouter API 配置"

if [ -z "$OPENROUTER_API_KEY" ]; then
    echo "⚠️  OPENROUTER_API_KEY 未设置"
    echo ""
    echo "请设置环境变量："
    echo "export OPENROUTER_API_KEY=\"sk-or-v1-xxxxxxxx\""
    echo "export OPENAI_API_KEY=\"\$OPENROUTER_API_KEY\""
    echo "export OPENAI_BASE_URL=\"https://openrouter.ai/api/v1\""
else
    echo "✅ OPENROUTER_API_KEY 已设置"
    
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
fi

# 测试命令
echo ""
echo "🧪 测试命令"
echo "1. 使用 npx:"
echo "   npx @steipete/summarize \"https://en.wikipedia.org/wiki/Artificial_intelligence\" --length short"
echo ""
echo "2. 使用包装脚本:"
echo "   summarize-npx \"https://example.com\" --model openrouter/openai/gpt-4o-mini"
echo ""
echo "3. 完整示例:"
cat > /tmp/test_summarize.sh << 'EOF'
#!/bin/bash
# 测试 summarize
URL="https://en.wikipedia.org/wiki/Artificial_intelligence"

echo "测试 URL: $URL"
echo ""

# 使用环境变量
export OPENAI_API_KEY="$OPENROUTER_API_KEY"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"

# 运行测试
npx @steipete/summarize "$URL" \
  --model openrouter/openai/gpt-4o-mini \
  --length short \
  --max-output-tokens 200
EOF

chmod +x /tmp/test_summarize.sh
echo "✅ 测试脚本已创建: /tmp/test_summarize.sh"

echo ""
echo "📚 使用说明"
echo "1. 确保有 OpenRouter API 密钥"
echo "2. 设置环境变量："
echo "   export OPENROUTER_API_KEY=\"your_key\""
echo "   export OPENAI_API_KEY=\"\$OPENROUTER_API_KEY\""
echo "   export OPENAI_BASE_URL=\"https://openrouter.ai/api/v1\""
echo "3. 运行测试：bash /tmp/test_summarize.sh"
echo ""
echo "🔧 备选方案"
echo "• 如果 npx 太慢，可以尝试全局安装"
echo "• 如果有 Docker，可以使用 Docker 版本"
echo "• 也可以考虑其他总结工具"

echo ""
echo "✅ 安装脚本完成"