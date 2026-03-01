#!/bin/bash
# summarize CLI 安装和配置脚本

set -e

echo "🔧 summarize CLI 安装和配置脚本"
echo "================================"

# 检查是否已安装
if command -v summarize &> /dev/null; then
    echo "✅ summarize CLI 已安装"
    summarize --version
else
    echo "📦 安装 summarize CLI..."
    
    # 尝试用 npm 安装
    echo "尝试 npm 安装..."
    if command -v npm &> /dev/null; then
        npm i -g @steipete/summarize
        if [ $? -eq 0 ]; then
            echo "✅ npm 安装成功"
        else
            echo "❌ npm 安装失败，尝试其他方法..."
            # 可以添加其他安装方法
        fi
    else
        echo "❌ npm 未安装"
        echo "请先安装 Node.js 和 npm"
        exit 1
    fi
    
    # 验证安装
    if command -v summarize &> /dev/null; then
        echo "✅ summarize CLI 安装成功"
        summarize --version
    else
        echo "❌ 安装失败，请手动安装"
        echo "参考: https://summarize.sh"
        exit 1
    fi
fi

echo ""
echo "🔑 配置 OpenRouter API"

# 询问 OpenRouter API 密钥
if [ -z "$OPENROUTER_API_KEY" ]; then
    echo "📋 需要配置 OpenRouter API 密钥"
    echo ""
    echo "请按以下步骤获取："
    echo "1. 访问 https://openrouter.ai"
    echo "2. 注册账号并登录"
    echo "3. 在 API Keys 页面生成密钥"
    echo "4. 将密钥粘贴到下方"
    echo ""
    read -p "请输入 OpenRouter API 密钥: " api_key
    
    if [ -n "$api_key" ]; then
        # 设置环境变量
        export OPENROUTER_API_KEY="$api_key"
        echo "✅ 环境变量已设置（当前会话有效）"
        
        # 保存到配置文件
        CONFIG_DIR="$HOME/.summarize"
        mkdir -p "$CONFIG_DIR"
        
        # 创建配置文件
        cat > "$CONFIG_DIR/config.json" << EOF
{
  "model": "openrouter/openai/gpt-4o-mini",
  "openrouter": {
    "api_key": "$api_key",
    "base_url": "https://openrouter.ai/api/v1"
  }
}
EOF
        
        echo "✅ 配置文件已创建: $CONFIG_DIR/config.json"
        
        # 可选：添加到 bashrc
        read -p "是否添加到 ~/.bashrc？(y/n): " save_choice
        if [[ "$save_choice" =~ ^[Yy]$ ]]; then
            echo "export OPENROUTER_API_KEY=\"$api_key\"" >> ~/.bashrc
            echo "✅ 已添加到 ~/.bashrc"
            echo "请运行 'source ~/.bashrc' 或重新打开终端"
        fi
    else
        echo "⚠️ 未输入 API 密钥，部分功能可能受限"
    fi
else
    echo "✅ OPENROUTER_API_KEY 已设置"
fi

# 创建 OpenRouter 专用的环境变量
echo ""
echo "🔄 设置 OpenRouter 环境变量"

# summarize 可能使用 OPENAI_API_KEY 变量，但指向 OpenRouter
if [ -n "$OPENROUTER_API_KEY" ]; then
    export OPENAI_API_KEY="$OPENROUTER_API_KEY"
    export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
    
    echo "✅ 已设置 OpenRouter 代理变量："
    echo "   OPENAI_API_KEY = $OPENROUTER_API_KEY"
    echo "   OPENAI_BASE_URL = https://openrouter.ai/api/v1"
    
    # 保存到临时文件供测试使用
    echo "export OPENAI_API_KEY=\"$OPENROUTER_API_KEY\"" > /tmp/summarize_env.sh
    echo "export OPENAI_BASE_URL=\"https://openrouter.ai/api/v1\"" >> /tmp/summarize_env.sh
fi

echo ""
echo "🧪 测试 summarize 功能"

# 测试命令
TEST_URL="https://en.wikipedia.org/wiki/Artificial_intelligence"

echo "测试 URL: $TEST_URL"
echo "测试命令: summarize \"$TEST_URL\" --length short"

# 运行测试（如果有API密钥）
if [ -n "$OPENROUTER_API_KEY" ]; then
    echo ""
    echo "🔍 开始测试..."
    
    # 使用环境变量运行
    source /tmp/summarize_env.sh 2>/dev/null || true
    summarize "$TEST_URL" --length short 2>&1 | head -100
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo ""
        echo "🎉 测试成功！summarize 功能正常"
    else
        echo ""
        echo "⚠️ 测试遇到问题，可能是："
        echo "  1. API 密钥无效"
        echo "  2. 网络连接问题"
        echo "  3. OpenRouter 服务异常"
    fi
else
    echo ""
    echo "⚠️ 未设置 API 密钥，跳过功能测试"
    echo "可以运行以下命令测试安装："
    echo "  summarize --help"
fi

echo ""
echo "📚 使用示例："
echo "  # 总结网页"
echo "  summarize \"https://example.com/article\" --length medium"
echo ""
echo "  # 使用 OpenRouter 模型"
echo "  summarize \"https://example.com\" --model openrouter/openai/gpt-4o"
echo ""
echo "  # 总结本地文件"
echo "  summarize \"/path/to/document.pdf\""
echo ""
echo "  # YouTube 视频总结"
echo "  summarize \"https://youtu.be/VIDEO_ID\" --youtube auto"
echo ""
echo "  # JSON 格式输出"
echo "  summarize \"https://example.com\" --json"

echo ""
echo "🔧 配置信息："
echo "  • 安装状态: $(command -v summarize &>/dev/null && echo '✅ 已安装' || echo '❌ 未安装')"
echo "  • OpenRouter API: $( [ -n "$OPENROUTER_API_KEY" ] && echo '✅ 已配置' || echo '❌ 未配置' )"
echo "  • 配置文件: $HOME/.summarize/config.json"
echo "  • 环境变量: OPENROUTER_API_KEY, OPENAI_API_KEY, OPENAI_BASE_URL"

echo ""
echo "✅ 配置完成！"