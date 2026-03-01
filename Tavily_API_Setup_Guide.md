# Tavily API 配置完整指南

## 📋 概述
Tavily 是一个为 AI 优化的网络搜索 API，专门设计用于 AI 代理，返回干净、相关的内容。

## 🔑 获取 API 密钥

### 步骤1：访问官网
1. 打开 https://tavily.com
2. 点击 "Get Started" 或 "Sign Up"

### 步骤2：注册账号
1. 使用邮箱注册
2. 完成邮箱验证
3. 登录账号

### 步骤3：获取 API 密钥
1. 登录后进入 **Dashboard**
2. 在左侧菜单找到 **API Keys**
3. 点击 **Generate New Key**
4. 复制生成的 API 密钥（格式如：`tvly-xxxxxx-xxxxxx-xxxxxx`）

### 步骤4：查看免费额度
- 新用户通常有免费试用额度（如 1000 次搜索/月）
- 在 Dashboard 查看剩余额度
- 注意使用限制和定价

## ⚙️ 配置方法

### 方法1：环境变量（推荐）
```bash
# 临时设置（当前终端有效）
export TAVILY_API_KEY="tvly-xxxxxxxxxxxxxxxxxxxxxxxx"

# 永久设置（添加到 bashrc）
echo 'export TAVILY_API_KEY="tvly-xxxxxxxxxxxxxxxxxxxxxxxx"' >> ~/.bashrc
source ~/.bashrc
```

### 方法2：使用配置脚本
```bash
# 运行我们创建的配置脚本
chmod +x /root/.openclaw/workspace/configure_tavily.sh
/root/.openclaw/workspace/configure_tavily.sh
```

### 方法3：OpenClaw 配置
```bash
# 添加到 OpenClaw 环境配置
openclaw config set env.TAVILY_API_KEY "tvly-xxxxxxxxxxxxxxxxxxxxxxxx"
```

## 🧪 测试配置

### 测试1：验证环境变量
```bash
echo $TAVILY_API_KEY
# 应该显示你的 API 密钥（前几位）
```

### 测试2：运行测试脚本
```bash
# 运行我们创建的测试脚本
/root/.openclaw/workspace/test_tavily.sh
```

### 测试3：手动测试
```bash
cd /root/.openclaw/workspace/skills/tavily-search

# 简单搜索测试
node scripts/search.mjs "AI news" -n 3

# 深度搜索测试
node scripts/search.mjs "event driven trading strategies" --deep

# 新闻搜索测试
node scripts/search.mjs "blockchain latest developments" --topic news --days 7
```

## 🚀 使用示例

### 基本搜索
```bash
# 简单搜索（返回5个结果）
node scripts/search.mjs "quantum computing advances"

# 指定结果数量（1-20个）
node scripts/search.mjs "AI market trends" -n 10

# 深度搜索（更全面但较慢）
node scripts/search.mjs "machine learning applications in finance" --deep
```

### 新闻搜索
```bash
# 科技新闻
node scripts/search.mjs "tech news" --topic news

# 最近3天的经济新闻
node scripts/search.mjs "economic news" --topic news --days 3

# 指定数量的新闻结果
node scripts/search.mjs "stock market news" --topic news -n 8
```

### 内容提取
```bash
# 提取网页内容
node scripts/extract.mjs "https://example.com/article"

# 提取并总结
node scripts/extract.mjs "https://news.example.com" | head -500
```

## 📊 输出格式

Tavily 返回 JSON 格式的结果：
```json
{
  "query": "搜索词",
  "answer": "AI生成的摘要（如果可用）",
  "results": [
    {
      "title": "结果标题",
      "url": "链接",
      "content": "内容摘要",
      "score": 0.95
    }
  ]
}
```

## 🎯 针对交易者的使用场景

### 市场研究
```bash
# 搜索特定公司新闻
node scripts/search.mjs "Apple earnings report" --topic news -n 5

# 行业趋势分析
node scripts/search.mjs "electric vehicle market trends" --deep

# 政策影响分析
node scripts/search.mjs "Federal Reserve interest rate impact" --topic news
```

### 技术分析
```bash
# 新技术动态
node scripts/search.mjs "AI trading algorithms" -n 8

# 区块链发展
node scripts/search.mjs "blockchain scalability solutions" --deep

# 量化交易策略
node scripts/search.mjs "quantitative trading strategies 2024" --deep
```

### 批量处理
```bash
#!/bin/bash
# 批量搜索脚本

SEARCH_TERMS=(
  "A股市场动态"
  "美股科技股表现"
  "区块链监管政策"
  "美联储会议纪要"
  "人民币汇率走势"
)

OUTPUT_FILE="market_research_$(date +%Y%m%d).md"

echo "# 市场研究摘要 $(date)" > "$OUTPUT_FILE"

for term in "${SEARCH_TERMS[@]}"; do
  echo "## $term" >> "$OUTPUT_FILE"
  node scripts/search.mjs "$term" --topic news -n 3 >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "✅ 批量搜索完成: $OUTPUT_FILE"
```

## 🔧 故障排除

### 常见错误

#### 1. "Missing TAVILY_API_KEY"
```bash
# 解决方案：设置环境变量
export TAVILY_API_KEY="your_key_here"
```

#### 2. "Invalid API key"
```bash
# 可能原因：
# - 密钥错误
# - 密钥过期
# - 账号无余额
# 解决方案：重新生成密钥或检查账号状态
```

#### 3. "Rate limit exceeded"
```bash
# 可能原因：
# - 免费额度用完
# - 请求过于频繁
# 解决方案：
# - 升级套餐
# - 降低请求频率
# - 使用缓存
```

#### 4. 网络错误
```bash
# 可能原因：
# - 网络连接问题
# - 防火墙限制
# - Tavily 服务异常
# 解决方案：
# - 检查网络连接
# - 尝试使用代理
# - 等待服务恢复
```

### 测试连接
```bash
# 测试 API 密钥有效性
curl -s -H "Authorization: Bearer $TAVILY_API_KEY" \
  https://api.tavily.com/health

# 测试搜索功能（简单查询）
node scripts/search.mjs "test" -n 1
```

## 💰 费用管理

### 定价模式
- **按搜索次数计费**
- 不同套餐有不同的月搜索限额
- 超出部分按次收费

### 免费额度
- 新用户通常有试用额度
- 查看 Dashboard 的 Usage 页面
- 监控使用情况避免超额

### 成本控制建议
1. **使用缓存**：避免重复搜索相同内容
2. **批量处理**：减少 API 调用次数
3. **优化查询**：使用具体的关键词
4. **监控使用**：定期检查使用量

## 📈 性能优化

### 搜索优化技巧
1. **使用具体关键词**：避免模糊查询
2. **合理使用深度搜索**：仅当需要全面信息时
3. **控制结果数量**：根据需求调整（默认5个）
4. **利用新闻搜索**：获取最新信息

### 速度优化
1. **并行处理**：同时进行多个搜索
2. **本地缓存**：缓存搜索结果
3. **预处理**：先提取再处理

### 质量优化
1. **使用深度搜索**：获得更全面的结果
2. **结合多个来源**：交叉验证信息
3. **后处理**：对结果进行二次分析

## 🔗 集成建议

### 与 summarize 集成
```bash
#!/bin/bash
# 搜索并总结工作流

# 1. 使用 Tavily 搜索
SEARCH_RESULTS=$(node scripts/search.mjs "AI trading strategies" --deep -n 5)

# 2. 提取关键信息
URLS=$(echo "$SEARCH_RESULTS" | jq -r '.results[].url' | head -3)

# 3. 使用 summarize 总结每个结果
for url in $URLS; do
  echo "处理: $url"
  npx @steipete/summarize "$url" \
    --model openrouter/openai/gpt-4o-mini \
    --length short
  echo "---"
done
```

### 与热点新闻推送集成
```bash
#!/bin/bash
# 自动生成热点新闻简报

# 搜索今日热点
TOPICS=("AI" "blockchain" "stock market" "technology")

for topic in "${TOPICS[@]}"; do
  echo "## $topic 热点"
  node scripts/search.mjs "$topic" --topic news --days 1 -n 3
  echo ""
done > daily_hot_topics.md

# 推送到飞书（如果配置了）
# openclaw message send --channel feishu --target "user:ou_xxx" --message "热点新闻已更新"
```

## 📁 相关文件

### 已创建的配置工具
1. **`configure_tavily.sh`** - 自动配置脚本
2. **`test_tavily.sh`** - 功能测试脚本
3. **`Tavily_Usage_Guide.md`** - 详细使用指南

### 技能文件位置
- 主目录：`/root/.openclaw/workspace/skills/tavily-search/`
- 搜索脚本：`scripts/search.mjs`
- 提取脚本：`scripts/extract.mjs`
- 技能文档：`SKILL.md`

## 🚀 快速开始

### 第一步：获取 API 密钥
1. 访问 https://tavily.com
2. 注册并获取 API 密钥

### 第二步：配置环境变量
```bash
export TAVILY_API_KEY="tvly-xxxxxxxxxxxxxxxxxxxxxxxx"
```

### 第三步：测试功能
```bash
cd /root/.openclaw/workspace/skills/tavily-search
node scripts/search.mjs "test search" -n 1
```

### 第四步：开始使用
```bash
# 搜索市场信息
node scripts/search.mjs "A股今日动态" --topic news

# 深度研究
node scripts/search.mjs "事件驱动交易策略" --deep -n 10
```

## ⚠️ 注意事项

1. **API 密钥安全**：不要泄露密钥
2. **使用限制**：注意免费额度和速率限制
3. **网络要求**：需要稳定的网络连接
4. **内容质量**：结果已为 AI 优化，但仍需验证

## 📞 技术支持

### Tavily 官方资源
- 官网：https://tavily.com
- 文档：https://docs.tavily.com
- 支持：support@tavily.com

### 本地支持
- 配置脚本：`configure_tavily.sh`
- 测试脚本：`test_tavily.sh`
- 使用指南：`Tavily_Usage_Guide.md`

---
*配置指南版本：1.0 | 最后更新：2026-03-01*