# Tavily Search 技能使用指南

## 📋 概述
Tavily Search 是一个为 AI 优化的网络搜索工具，专门设计用于 AI 代理，返回干净、相关的搜索结果。

## 🔑 API 密钥获取
1. **访问网站**: https://tavily.com
2. **注册账号**: 使用邮箱注册
3. **获取密钥**: 登录后进入 Dashboard → API Keys → Generate New Key
4. **免费额度**: 通常提供免费试用额度（如 1000 次搜索/月）

## ⚙️ 配置方法

### 方法1：环境变量（推荐）
```bash
# 临时设置（当前终端）
export TAVILY_API_KEY="tvly-xxxxxx-xxxxxx-xxxxxx"

# 永久设置
echo 'export TAVILY_API_KEY="tvly-xxxxxx-xxxxxx-xxxxxx"' >> ~/.bashrc
source ~/.bashrc
```

### 方法2：OpenClaw 配置
```bash
openclaw config set env.TAVILY_API_KEY "tvly-xxxxxx-xxxxxx-xxxxxx"
```

### 方法3：使用配置脚本
```bash
cd /root/.openclaw/workspace
./configure_tavily.sh
```

## 🚀 基本使用

### 搜索命令
```bash
cd /root/.openclaw/workspace/skills/tavily-search

# 基本搜索
node scripts/search.mjs "查询词"

# 指定结果数量（1-20）
node scripts/search.mjs "查询词" -n 10

# 深度搜索（更全面）
node scripts/search.mjs "查询词" --deep

# 新闻搜索
node scripts/search.mjs "查询词" --topic news

# 最近7天的新闻
node scripts/search.mjs "查询词" --topic news --days 7
```

### 内容提取
```bash
# 提取网页内容
node scripts/extract.mjs "https://example.com/article"
```

## 📊 输出格式
Tavily 返回 JSON 格式的结果，包含：
- `query`: 搜索词
- `answer`: AI 生成的摘要（如果可用）
- `results`: 搜索结果数组
  - `title`: 标题
  - `url`: 链接
  - `content`: 内容摘要
  - `score`: 相关度分数

## 🎯 使用场景

### 1. 快速研究
```bash
# 获取技术信息
node scripts/search.mjs "OpenClaw AI 功能" -n 5

# 获取最新新闻
node scripts/search.mjs "AI 市场动态" --topic news --days 3
```

### 2. 深度分析
```bash
# 深度研究模式
node scripts/search.mjs "事件驱动交易策略" --deep -n 10
```

### 3. 内容收集
```bash
# 提取特定文章
node scripts/extract.mjs "https://news.example.com/ai-trends"
```

### 4. 市场监控
```bash
# 监控特定主题
node scripts/search.mjs "区块链最新进展" --topic news -n 8
```

## 🔧 集成到 OpenClaw

### 作为工具使用
你可以在 OpenClaw 会话中直接调用：
```bash
exec: cd /root/.openclaw/workspace/skills/tavily-search && node scripts/search.mjs "查询词"
```

### 创建快捷命令
在 `TOOLS.md` 中添加：
```markdown
### Tavily Search
- 搜索: `tavily-search "关键词"`
- 深度搜索: `tavily-search-deep "关键词"`
- 新闻搜索: `tavily-news "关键词"`
```

创建对应的 shell 函数：
```bash
tavily-search() {
    cd /root/.openclaw/workspace/skills/tavily-search
    node scripts/search.mjs "$1" ${2:+-n $2}
}

tavily-search-deep() {
    cd /root/.openclaw/workspace/skills/tavily-search
    node scripts/search.mjs "$1" --deep ${2:+-n $2}
}
```

## ⚠️ 注意事项

### 速率限制
- 免费版通常有调用限制
- 付费版提供更高额度
- 监控使用情况避免超额

### 网络要求
- 需要稳定的网络连接
- 可能受地区限制影响

### 内容质量
- 结果已为 AI 优化
- 可能过滤某些类型内容
- 深度搜索更全面但更慢

## 🛠️ 故障排除

### 常见错误
1. **"Missing TAVILY_API_KEY"**
   - 检查环境变量是否设置
   - 运行 `echo $TAVILY_API_KEY`

2. **"Invalid API key"**
   - 确认密钥是否正确
   - 检查密钥是否过期

3. **网络错误**
   - 检查网络连接
   - 尝试其他网络

4. **额度不足**
   - 检查账号剩余额度
   - 升级套餐或等待重置

### 测试命令
```bash
# 测试环境变量
echo "API Key: ${TAVILY_API_KEY:0:10}..."

# 测试简单搜索
cd /root/.openclaw/workspace/skills/tavily-search
node scripts/search.mjs "test" -n 1
```

## 📈 最佳实践

### 搜索优化
1. **使用具体关键词** - 避免模糊查询
2. **合理使用深度搜索** - 仅当需要全面信息时
3. **控制结果数量** - 根据需求调整（默认5个）
4. **利用新闻搜索** - 获取最新信息

### 性能考虑
1. **缓存结果** - 重复查询可缓存
2. **批量处理** - 避免频繁小查询
3. **异步调用** - 长时间搜索使用异步

### 成本控制
1. **监控使用量** - 定期检查额度
2. **优化查询** - 减少不必要搜索
3. **使用免费额度** - 合理规划使用

## 🔗 相关资源
- [Tavily 官网](https://tavily.com)
- [API 文档](https://docs.tavily.com)
- [OpenClaw 技能目录](https://clawhub.com)
- [配置脚本](./configure_tavily.sh)

---
*最后更新: 2026-03-01*