# summarize 快速使用指南

## ⚡ 立即使用

### 基本命令
```bash
# 总结网页
npx @steipete/summarize "https://example.com/article"

# 总结文本（管道输入）
echo "你的文本内容" | npx @steipete/summarize -

# 使用 OpenRouter 特定模型
npx @steipete/summarize "https://example.com" \
  --model openrouter/openai/gpt-4o-mini
```

### 环境变量（已配置）
```bash
export OPENROUTER_API_KEY="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"
export OPENAI_API_KEY="$OPENROUTER_API_KEY"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
```

## 🎯 常用选项

### 控制输出
```bash
--length short      # 简短总结（默认）
--length medium     # 中等长度
--length long       # 详细总结
--max-output-tokens 300  # 限制输出token数
```

### 格式选项
```bash
--json             # JSON格式输出
--extract-only     # 仅提取内容，不总结
```

### 模型选择
```bash
--model openrouter/openai/gpt-4o-mini      # 性价比高
--model openrouter/openai/gpt-4o           # 功能强大
--model openrouter/anthropic/claude-3.5-sonnet  # 长文本优秀
--model openrouter/google/gemini-2.0-flash-exp  # 快速响应
```

## 📊 交易者专用示例

### 市场报告分析
```bash
# 总结PDF研究报告
npx @steipete/summarize "market-analysis.pdf" \
  --model openrouter/anthropic/claude-3.5-sonnet \
  --length long

# 提取关键数据
npx @steipete/summarize "research-report.pdf" \
  --extract-only | grep -i "target\|price\|growth\|forecast"
```

### 新闻监控
```bash
# 快速浏览多个新闻源
URLS=(
  "https://finance-news1.com"
  "https://market-update.com" 
  "https://tech-analysis.com"
)

for url in "${URLS[@]}"; do
  echo "=== $url ==="
  npx @steipete/summarize "$url" \
    --model openrouter/openai/gpt-4o-mini \
    --length short
  echo ""
done > daily_news_summary.md
```

### 视频内容分析
```bash
# 总结财经YouTube视频（需要APIFY_API_TOKEN）
export APIFY_API_TOKEN="your_apify_token"
npx @steipete/summarize "https://youtu.be/finance-video" \
  --youtube auto \
  --model openrouter/google/gemini-2.0-flash-exp \
  --length medium
```

### 批量处理脚本
```bash
#!/bin/bash
# batch_summarize.sh - 批量处理URL列表

INPUT_FILE="urls.txt"
OUTPUT_FILE="summaries_$(date +%Y%m%d).md"

echo "# 每日摘要 $(date)" > "$OUTPUT_FILE"

while IFS= read -r url; do
  if [ -n "$url" ]; then
    echo "## $(echo "$url" | cut -d'/' -f3)" >> "$OUTPUT_FILE"
    npx @steipete/summarize "$url" \
      --model openrouter/openai/gpt-4o-mini \
      --length short >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
done < "$INPUT_FILE"

echo "✅ 批量处理完成: $OUTPUT_FILE"
```

## 🔧 故障排除

### 常见问题
1. **"Failed to fetch HTML document"**
   - 网站可能有防爬虫机制
   - 尝试使用 `--firecrawl auto`（需要FIRECRAWL_API_KEY）
   - 换一个网站测试

2. **"Invalid API key"**
   - 检查 OpenRouter API 密钥是否正确
   - 确认账号有余额
   - 验证环境变量是否设置

3. **运行缓慢**
   - 使用更快的模型：`--model openrouter/openai/gpt-4o-mini`
   - 减少输出长度：`--length short`
   - 限制token数：`--max-output-tokens 150`

### 测试命令
```bash
# 测试基本功能
echo "测试文本" | npx @steipete/summarize - \
  --model openrouter/openai/gpt-4o-mini \
  --length short

# 测试API连接
curl -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  https://openrouter.ai/api/v1/models | jq '.data[0].id'
```

## 📈 性能建议

### 成本优化
- 使用 `gpt-4o-mini` 而非 `gpt-4o`（便宜10倍）
- 设置 `--max-output-tokens` 限制输出长度
- 批量处理减少API调用次数

### 速度优化  
- Gemini Flash 模型响应最快
- 本地文件处理快于网页抓取
- 并行处理多个任务

### 质量优化
- 复杂内容使用 Claude 3.5 Sonnet
- 增加 `--length` 参数获得更详细总结
- 对重要内容进行二次处理

## 📁 相关文件
- 配置脚本：`configure_summarize.sh`
- 测试脚本：`test_summarize_simple.sh`
- 使用指南：`OpenRouter_Config_Guide.md`
- 配置文件：`~/.summarize/config.json`

## 🚀 下一步
1. 尝试总结你的第一个市场报告
2. 设置定时任务自动收集新闻摘要
3. 集成到交易分析工作流中
4. 探索 YouTube 视频总结功能

---
*配置完成时间：2026-03-01 09:31 GMT+8*