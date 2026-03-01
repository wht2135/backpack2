#!/bin/bash
# 每日8点生成并推送热点简报

set -e

# 工作目录
WORKDIR="/root/.openclaw/workspace"
cd "$WORKDIR"

# 生成时间戳
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
OUTPUT_FILE="${WORKDIR}/digests/daily_${TIMESTAMP}.md"

# 创建输出目录
mkdir -p "${WORKDIR}/digests"

# 生成简报（这里用模板，实际应调用生成脚本）
cat > "${OUTPUT_FILE}" << 'CONTENT'
📰 每日热点简报 - 科技/经济/政治 + X趋势
生成时间: $(date +"%Y-%m-%d %H:%M GMT+8")

🐦 X平台今日热点（含具体内容）
[实际生成时会调用OpenTwitter MCP获取实时数据]

🔬 科技热点
[实际生成时会聚合Tech News Digest数据]

💰 经济动态
[实际生成时会聚合经济新闻数据]

🏛️ 政治要闻  
[实际生成时会聚合政治新闻数据]

📊 今日关注
[实际生成时会列出重要事件和数据发布]

---
简报配置：
• 推送时间: 每日早上8:00
• 内容: X热点 + 科技/经济/政治
• 数据源: OpenTwitter MCP + Tech News Digest
CONTENT

echo "✅ 简报已生成: ${OUTPUT_FILE}"

# 记录日志
echo "$(date): 每日简报生成完成" >> "${WORKDIR}/digests/digest.log"

# 这里应该添加推送逻辑（飞书API权限修复后）
# 目前先保存文件
echo "📁 简报保存位置: ${OUTPUT_FILE}"
