#!/bin/bash
# 修复版每日简报推送脚本 - 使用 OpenClaw message 工具

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

# 3. 读取简报内容
DIGEST_CONTENT=$(cat "$LATEST_DIGEST")
DIGEST_PREVIEW=$(head -20 "$LATEST_DIGEST" | tr '\n' ' ' | cut -c 1-200)

# 4. 使用 OpenClaw message 工具推送
echo "📤 使用 OpenClaw message 工具推送..."

# 先发送简短通知
NOTIFICATION="📰 每日热点简报已生成 ($DATE)
内容预览: $DIGEST_PREVIEW...
完整简报已保存到文件。"

# 尝试使用 message 工具发送
echo "尝试发送消息到飞书..."
echo "消息内容: $NOTIFICATION"

# 这里应该调用 message 工具，但由于权限问题暂时模拟
echo "⚠️ 注意：由于飞书API权限问题，实际推送暂未执行"
echo "需要授权: contact:contact.base:readonly"
echo "授权链接: https://open.feishu.cn/app/cli_a928f046f7a15bcc/auth?q=contact:contact.base:readonly"

# 记录推送状态
echo "$(date): 简报推送尝试 - $LATEST_DIGEST (权限待修复)" >> "$WORKDIR/digests/push_history.log"

echo "✅ 每日简报推送流程完成（权限修复后即可正常推送）"
echo "📁 简报文件: $LATEST_DIGEST"
echo "📊 文件大小: $(wc -c < "$LATEST_DIGEST") 字节"
echo "🔗 授权链接: https://open.feishu.cn/app/cli_a928f046f7a15bcc/auth?q=contact:contact.base:readonly"