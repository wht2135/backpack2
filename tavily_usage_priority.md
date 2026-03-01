# Tavily Search 使用优先级策略

## 🎯 核心原则
**优先使用免费/低成本资源，Tavily 作为备用方案**

## 📊 优先级层次

### 第一层：本地资源（零成本）
```bash
# 1. 本地文件搜索
grep -r "关键词" /root/.openclaw/workspace/memory/
grep -r "关键词" /root/.openclaw/workspace/digests/

# 2. 记忆系统查询
cat /root/.openclaw/workspace/MEMORY.md | grep -i "关键词"
find /root/.openclaw/workspace/memory/ -name "*.md" -exec grep -l "关键词" {} \;

# 3. 技能文档搜索
find /root/.openclaw/workspace/skills/ -name "*.md" -exec grep -l "关键词" {} \;
```

### 第二层：缓存系统（低成本）
```bash
# 1. 检查缓存目录
CACHE_DIR="/root/.openclaw/workspace/cache/tavily/"
mkdir -p "$CACHE_DIR"

# 2. 缓存查询结果（24小时有效）
CACHE_FILE="${CACHE_DIR}$(echo "查询词" | md5sum | cut -d' ' -f1).json"
if [ -f "$CACHE_FILE" ] && [ $(date -r "$CACHE_FILE" +%s) -gt $(date -d "24 hours ago" +%s) ]; then
    echo "✅ 使用缓存结果"
    cat "$CACHE_FILE"
    exit 0
fi
```

### 第三层：替代搜索工具（低成本）
```bash
# 1. 使用 agent-browser 访问已知网站
# 2. 使用 summarize 处理已有文档
# 3. 使用内置的 web_search/web_fetch 工具
```

### 第四层：Tavily Search（消耗额度）
```bash
# 仅当以上方法都无法获取信息时使用
# 并且根据查询重要性分级使用
```

## 🔢 查询重要性分级

### A级：关键交易信息（可使用 Tavily）
```bash
# 1. 紧急市场事件
# 2. 重大政策变化
# 3. 公司突发新闻
# 4. 影响投资决策的关键信息

# 使用策略：深度搜索 + 新闻搜索
node scripts/search.mjs "美联储紧急会议" --topic news --deep
```

### B级：重要研究信息（谨慎使用）
```bash
# 1. 行业趋势分析
# 2. 公司基本面研究
# 3. 技术发展动态
# 4. 长期投资策略

# 使用策略：普通搜索，限制结果数量
node scripts/search.mjs "新能源汽车行业趋势" -n 3
```

### C级：一般信息查询（避免使用）
```bash
# 1. 基础概念解释
# 2. 历史数据查询
# 3. 通用知识获取
# 4. 非紧急信息

# 使用策略：优先使用本地资源或缓存
# 仅在必要时使用简单搜索
node scripts/search.mjs "AI基本概念" -n 1
```

## ⚙️ 智能使用脚本

### 智能搜索包装器
```bash
#!/bin/bash
# smart_search.sh - 智能搜索包装器

QUERY="$1"
PRIORITY="${2:-C}"  # 默认C级

# 检查本地缓存
check_cache() {
    local cache_file="/root/.openclaw/workspace/cache/tavily/$(echo "$QUERY" | md5sum | cut -d' ' -f1).json"
    if [ -f "$cache_file" ] && [ $(date -r "$cache_file" +%s) -gt $(date -d "24 hours ago" +%s) ]; then
        echo "📦 使用缓存结果"
        cat "$cache_file"
        return 0
    fi
    return 1
}

# 检查本地文件
check_local() {
    echo "🔍 搜索本地文件..."
    local results=$(grep -r -i "$QUERY" /root/.openclaw/workspace/memory/ 2>/dev/null | head -5)
    if [ -n "$results" ]; then
        echo "✅ 本地找到相关信息"
        echo "$results"
        return 0
    fi
    return 1
}

# 根据优先级决定搜索策略
case "$PRIORITY" in
    A)
        echo "🚨 A级查询：使用深度搜索"
        if check_cache || check_local; then
            exit 0
        fi
        # 使用 Tavily 深度搜索
        node scripts/search.mjs "$QUERY" --deep -n 5
        ;;
    B)
        echo "📊 B级查询：使用普通搜索"
        if check_cache || check_local; then
            exit 0
        fi
        # 使用 Tavily 普通搜索
        node scripts/search.mjs "$QUERY" -n 3
        ;;
    C)
        echo "📝 C级查询：优先本地资源"
        if check_local; then
            exit 0
        fi
        if check_cache; then
            exit 0
        fi
        # 最后才使用 Tavily
        echo "⚠️  本地无结果，使用简单搜索"
        node scripts/search.mjs "$QUERY" -n 1
        ;;
    *)
        echo "❌ 无效优先级"
        exit 1
        ;;
esac

# 缓存结果
mkdir -p /root/.openclaw/workspace/cache/tavily/
CACHE_FILE="/root/.openclaw/workspace/cache/tavily/$(echo "$QUERY" | md5sum | cut -d' ' -f1).json"
node scripts/search.mjs "$QUERY" -n 1 > "$CACHE_FILE" 2>/dev/null &
```

### 每日额度监控脚本
```bash
#!/bin/bash
# monitor_tavily_usage.sh - 监控 Tavily 使用情况

LOG_FILE="/root/.openclaw/workspace/logs/tavily_usage.log"
mkdir -p "$(dirname "$LOG_FILE")"

# 记录本次使用
echo "$(date): $1 (优先级: $2)" >> "$LOG_FILE"

# 统计今日使用次数
TODAY=$(date +%Y-%m-%d)
TODAY_COUNT=$(grep "$TODAY" "$LOG_FILE" | wc -l)

# 显示使用统计
echo "📊 Tavily 使用统计"
echo "今日日期: $TODAY"
echo "今日使用次数: $TODAY_COUNT"

# 警告阈值
WARNING_THRESHOLD=10
CRITICAL_THRESHOLD=20

if [ "$TODAY_COUNT" -ge "$CRITICAL_THRESHOLD" ]; then
    echo "🚨 警告：今日使用已达 $TODAY_COUNT 次，接近免费额度限制！"
    echo "建议：暂停非必要查询，优先使用本地资源"
elif [ "$TODAY_COUNT" -ge "$WARNING_THRESHOLD" ]; then
    echo "⚠️  注意：今日使用 $TODAY_COUNT 次，请谨慎使用"
fi

# 显示最近查询
echo ""
echo "最近5次查询："
tail -5 "$LOG_FILE"
```

## 🎯 具体使用场景策略

### 场景1：市场新闻监控
```bash
# 策略：每天只查询1次，缓存结果
if [ ! -f "/tmp/market_news_$(date +%Y%m%d).cache" ]; then
    # 使用 Tavily 获取当日新闻
    node scripts/search.mjs "财经新闻" --topic news --days 1 -n 5 > "/tmp/market_news_$(date +%Y%m%d).cache"
fi
cat "/tmp/market_news_$(date +%Y%m%d).cache"
```

### 场景2：公司研究
```bash
# 策略：每周更新一次，使用缓存
COMPANY="Apple"
CACHE_FILE="/root/.openclaw/workspace/cache/companies/${COMPANY}_$(date +%Y%U).json"

if [ ! -f "$CACHE_FILE" ]; then
    # 每周只查询一次
    node scripts/search.mjs "$COMPANY earnings" --topic news --days 7 -n 3 > "$CACHE_FILE"
fi
cat "$CACHE_FILE"
```

### 场景3：技术概念查询
```bash
# 策略：优先本地知识库，最后使用 Tavily
CONCEPT="区块链技术"

# 1. 检查本地文档
if grep -r -i "$CONCEPT" /root/.openclaw/workspace/memory/; then
    echo "✅ 本地找到相关信息"
    exit 0
fi

# 2. 检查缓存
CACHE_FILE="/root/.openclaw/workspace/cache/concepts/$(echo "$CONCEPT" | md5sum | cut -d' ' -f1).json"
if [ -f "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
    exit 0
fi

# 3. 最后使用 Tavily（简单查询）
node scripts/search.mjs "$CONCEPT" -n 1 > "$CACHE_FILE"
cat "$CACHE_FILE"
```

## 📈 额度管理计划

### 每日配额分配
```bash
# 假设免费额度：1000次/月 ≈ 33次/天
# 分配策略：
# - A级查询：5次/天（紧急重要信息）
# - B级查询：10次/天（重要研究）
# - C级查询：18次/天（一般查询）
# 总计：33次/天，留有余量
```

### 月度监控
```bash
#!/bin/bash
# monthly_quota_check.sh

LOG_FILE="/root/.openclaw/workspace/logs/tavily_usage.log"
CURRENT_MONTH=$(date +%Y-%m)
MONTHLY_COUNT=$(grep "$CURRENT_MONTH" "$LOG_FILE" | wc -l)

echo "📅 月度使用统计 ($CURRENT_MONTH)"
echo "本月使用次数: $MONTHLY_COUNT"

FREE_QUOTA=1000
REMAINING=$((FREE_QUOTA - MONTHLY_COUNT))
DAYS_IN_MONTH=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)
DAYS_PASSED=$(date +%d)
DAYS_REMAINING=$((DAYS_IN_MONTH - DAYS_PASSED))

if [ "$REMAINING" -le 0 ]; then
    echo "🚨 本月额度已用完！"
    echo "请升级套餐或等待下月重置"
elif [ "$REMAINING" -lt 100 ]; then
    echo "⚠️  本月剩余额度仅 $REMAINING 次"
    echo "建议：严格控制使用，优先本地资源"
else
    echo "✅ 本月剩余额度: $REMAINING 次"
    echo "日均可用: $((REMAINING / DAYS_REMAINING)) 次/天"
fi
```

## 🔧 实施步骤

### 第一步：创建缓存目录
```bash
mkdir -p /root/.openclaw/workspace/cache/tavily/
mkdir -p /root/.openclaw/workspace/cache/companies/
mkdir -p /root/.openclaw/workspace/cache/concepts/
mkdir -p /root/.openclaw/workspace/logs/
```

### 第二步：创建智能搜索别名
```bash
# 添加到 ~/.bashrc
alias smart-search="/root/.openclaw/workspace/smart_search.sh"
alias check-usage="/root/.openclaw/workspace/monitor_tavily_usage.sh"
```

### 第三步：使用示例
```bash
# A级查询（紧急重要）
smart-search "美联储紧急降息" A

# B级查询（重要研究）
smart-search "特斯拉财报分析" B

# C级查询（一般信息）
smart-search "Python基础语法" C

# 检查使用情况
check-usage "查询示例" B
```

## 💡 最佳实践

### 1. **查询优化**
- 使用具体关键词，避免模糊查询
- 组合搜索词，提高命中率
- 优先使用已有知识的扩展查询

### 2. **结果复用**
- 相同查询24小时内使用缓存
- 相关查询复用部分结果
- 批量处理相关主题

### 3. **本地知识库建设**
- 将重要查询结果保存到本地
- 建立主题知识库
- 定期更新本地缓存

### 4. **额度预留**
- 每日预留5次紧急查询额度
- 重要日期（财报季、政策发布日）增加配额
- 月末减少使用，避免超额

## 🚨 紧急情况处理

### 额度用尽时
```bash
#!/bin/bash
# fallback_search.sh - 额度用尽时的备用方案

QUERY="$1"

echo "⚠️  Tavily 额度可能已用尽，使用备用方案"

# 方案1：使用 web_search 工具（如果可用）
# 方案2：使用 agent-browser 访问特定网站
# 方案3：使用本地知识库
# 方案4：提示用户手动搜索

echo "建议："
echo "1. 手动访问：https://www.google.com/search?q=$(echo "$QUERY" | sed 's/ /+/g')"
echo "2. 检查本地文件：grep -r \"$QUERY\" /root/.openclaw/workspace/"
echo "3. 等待额度重置或升级套餐"
```

## ✅ 总结

### 核心策略
1. **本地优先**：充分利用已有资源
2. **缓存为王**：避免重复查询
3. **分级使用**：根据重要性分配额度
4. **监控预警**：实时掌握使用情况

### 预期效果
- **额度节省**：减少50%以上的不必要查询
- **响应速度**：缓存查询快于网络查询
- **系统稳定**：避免额度突然用尽
- **知识积累**：本地知识库不断丰富

**通过智能优先级管理，可以在保证关键信息获取的同时，最大化免费额度的使用效率。** 🎯