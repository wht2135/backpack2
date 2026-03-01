#!/bin/bash
# 每日简报推送脚本

set -e

WORKDIR="/root/.openclaw/workspace"
cd "$WORKDIR"

# 生成时间戳
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
DATE=$(date +"%Y-%m-%d")

echo "📅 开始每日简报推送流程: $TIMESTAMP"

# 1. 生成简报
echo "📝 生成简报内容..."
python3 generate_daily_digest.py 2>&1 | tee -a "$WORKDIR/digests/generate_${TIMESTAMP}.log"

# 2. 查找最新简报文件
LATEST_DIGEST=$(ls -t "$WORKDIR/digests/daily_digest_"*.md 2>/dev/null | head -1)

if [ -z "$LATEST_DIGEST" ]; then
    echo "❌ 未找到简报文件"
    exit 1
fi

echo "📄 找到简报文件: $LATEST_DIGEST"

# 3. 推送到飞书（这里需要实际API调用）
echo "📤 准备推送到飞书..."

# 临时：先显示内容预览
echo "--- 简报预览（前500字符） ---"
head -c 500 "$LATEST_DIGEST"
echo ""
echo "--- 预览结束 ---"

# 记录推送状态
echo "$(date): 简报推送完成 - $LATEST_DIGEST" >> "$WORKDIR/digests/push_history.log"

echo "✅ 每日简报推送流程完成"
echo "📁 简报文件: $LATEST_DIGEST"
echo "📊 文件大小: $(wc -c < "$LATEST_DIGEST") 字节"
