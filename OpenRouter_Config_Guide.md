# OpenRouter API 配置指南

## 📋 概述
OpenRouter 是一个统一的 AI API 网关，支持多个模型提供商（OpenAI、Anthropic、Google、xAI 等）。通过 OpenRouter 可以使用单个 API 密钥访问多种模型。

## 🔑 获取 API 密钥

### 步骤1：注册账号
1. 访问 https://openrouter.ai
2. 点击 "Sign Up" 注册账号
3. 使用邮箱注册并验证

### 步骤2：获取 API 密钥
1. 登录后进入 Dashboard
2. 点击左侧 "API Keys"
3. 点击 "Create Key" 生成新密钥
4. 复制生成的密钥

### 步骤3：查看可用模型
1. 在 Dashboard 点击 "Models"
2. 查看所有可用模型及其定价
3. 推荐模型：
   - `openrouter/openai/gpt-4o-mini` - 性价比高
   - `openrouter/openai/gpt-4o` - 功能强大
   - `openrouter/anthropic/claude-3.5-sonnet` - 长文本处理
   - `openrouter/google/gemini-2.0-flash-exp` - 快速响应

## ⚙️ 配置 summarize 使用 OpenRouter

### 方法1：环境变量
```bash
# 设置 OpenRouter API 密钥
export OPENROUTER_API_KEY="sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxx"

# summarize 可能使用 OPENAI 变量，需要设置代理
export OPENAI_API_KEY="$OPENROUTER_API_KEY"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
```

### 方法2：配置文件
创建 `~/.summarize/config.json`：
```json
{
  "model": "openrouter/openai/gpt-4o-mini",
  "openrouter": {
    "api_key": "sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxx",
    "base_url": "https://openrouter.ai/api/v1"
  }
}
```

### 方法3：命令行指定
```bash
# 直接指定模型
summarize "https://example.com" --model openrouter/openai/gpt-4o

# 或使用环境变量
OPENAI_API_KEY="sk-or-v1-xxx" OPENAI_BASE_URL="https://openrouter.ai/api/v1" summarize "https://example.com"
```

## 🚀 使用示例

### 基本使用
```bash
# 使用 OpenRouter 的 GPT-4o Mini
summarize "https://news.example.com/article" --model openrouter/openai/gpt-4o-mini

# 使用 Claude 模型
summarize "/path/to/report.pdf" --model openrouter/anthropic/claude-3.5-sonnet

# 使用 Gemini 模型
summarize "https://youtu.be/VIDEO_ID" --model openrouter/google/gemini-2.0-flash-exp --youtube auto
```

### 高级配置
```bash
# 指定输出长度
summarize "https://example.com" --length medium --model openrouter/openai/gpt-4o

# JSON 格式输出
summarize "https://example.com" --json --model openrouter/openai/gpt-4o-mini

# 仅提取内容
summarize "https://example.com" --extract-only

# 指定最大 token 数
summarize "https://example.com" --max-output-tokens 500 --model openrouter/anthropic/claude-3.5-sonnet
```

## 💰 费用说明

### 定价模式
- 按 token 计费（输入 + 输出）
- 不同模型价格不同
- 有免费额度（新用户通常有试用额度）

### 费用估算
- GPT-4o Mini: ~$0.15/1M tokens
- Claude 3.5 Sonnet: ~$3.00/1M tokens
- Gemini 2.0 Flash: ~$0.10/1M tokens

### 监控使用
1. 登录 OpenRouter Dashboard
2. 查看 "Usage" 页面
3. 设置预算提醒

## 🔧 故障排除

### 常见错误
1. **"Invalid API key"**
   - 检查密钥是否正确
   - 确认密钥未过期
   - 验证账号是否有余额

2. **"Model not found"**
   - 检查模型名称拼写
   - 确认模型在 OpenRouter 上可用
   - 尝试其他模型

3. **"Rate limit exceeded"**
   - 降低请求频率
   - 升级账号套餐
   - 使用 cheaper 模型

4. **"Network error"**
   - 检查网络连接
   - 验证 OpenRouter 服务状态
   - 尝试使用代理

### 测试连接
```bash
# 测试 API 密钥
curl -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  https://openrouter.ai/api/v1/models

# 测试 summarize 连接
summarize "https://en.wikipedia.org/wiki/Artificial_intelligence" \
  --model openrouter/openai/gpt-4o-mini \
  --length short
```

## 🎯 针对交易者的使用场景

### 市场研究报告
```bash
# 总结长篇 PDF 报告
summarize "/path/to/market-analysis.pdf" \
  --model openrouter/anthropic/claude-3.5-sonnet \
  --length long

# 提取关键数据点
summarize "https://research-firm.com/report" \
  --extract-only | grep -i "target\|price\|growth"
```

### 新闻监控
```bash
# 批量处理新闻链接
for url in \
  "https://finance-news.com/article1" \
  "https://market-update.com/article2" \
  "https://tech-analysis.com/article3"
do
  summarize "$url" \
    --model openrouter/openai/gpt-4o-mini \
    --length short >> daily_news_summary.md
  echo "---" >> daily_news_summary.md
done
```

### 视频内容分析
```bash
# 总结财经 YouTube 视频
summarize "https://youtu.be/finance-video-id" \
  --youtube auto \
  --model openrouter/google/gemini-2.0-flash-exp \
  --length medium
```

### 技术文档
```bash
# 快速了解新技术
summarize "https://arxiv.org/abs/2401.12345" \
  --model openrouter/openai/gpt-4o \
  --length medium

# 提取技术规格
summarize "https://developer.company.com/api-docs" \
  --extract-only | grep -i "endpoint\|parameter\|response"
```

## 📊 性能优化

### 成本控制
1. **使用便宜模型**：GPT-4o Mini 或 Gemini Flash
2. **控制输出长度**：使用 `--length short`
3. **批量处理**：减少 API 调用次数
4. **缓存结果**：避免重复处理相同内容

### 速度优化
1. **选择快速模型**：Gemini Flash 响应最快
2. **并行处理**：同时处理多个文档
3. **本地缓存**：缓存提取的内容
4. **预处理**：先提取再总结

### 质量优化
1. **选择合适模型**：复杂内容用 Claude，简单内容用 GPT-4o Mini
2. **调整参数**：适当增加 `--max-output-tokens`
3. **分段处理**：长文档分段总结
4. **后处理**：对总结结果进行二次整理

## 🔗 相关资源
- [OpenRouter 官网](https://openrouter.ai)
- [API 文档](https://openrouter.ai/docs)
- [模型列表](https://openrouter.ai/models)
- [定价页面](https://openrouter.ai/pricing)
- [summarize GitHub](https://github.com/steipete/summarize)

---
*最后更新: 2026-03-01*