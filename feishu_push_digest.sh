#!/bin/bash
# 飞书推送版每日简报脚本 - 集成实际API调用

set -e

WORKDIR="/root/.openclaw/workspace"
cd "$WORKDIR"

# 生成时间戳
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
DATE=$(date +"%Y-%m-%d")
TIME_NOW=$(date +"%H:%M")

echo "📅 开始每日简报推送流程: $TIMESTAMP"
echo "🔧 使用集成飞书API推送"

# 1. 生成简报
echo "📝 生成简报内容..."
python3 generate_daily_digest.py 2>&1 | tee -a "$WORKDIR/digests/generate_${TIMESTAMP}.log"

# 2. 查找最新简报文件
LATEST_DIGEST=$(ls -t "$WORKDIR/digests/daily_digest_"*.md 2>/dev/null | head -1)

if [ -z "$LATEST_DIGEST" ]; then
    echo "❌ 未找到简报文件"
    # 发送错误通知
    openclaw message send --channel feishu --target "user:ou_4b43037f4903b00868b089beef5cc6d2" \
        --message "❌ 每日简报生成失败\n时间: $DATE $TIME_NOW\n错误: 未找到简报文件" 2>/dev/null || true
    exit 1
fi

echo "📄 找到简报文件: $LATEST_DIGEST"

# 3. 读取简报内容
DIGEST_CONTENT=$(cat "$LATEST_DIGEST")
FILE_SIZE=$(wc -c < "$LATEST_DIGEST")
LINE_COUNT=$(wc -l < "$LATEST_DIGEST")

# 4. 分割内容（飞书消息有长度限制）
split_digest() {
    local content="$1"
    local max_length=1500  # 飞书消息建议长度
    
    # 按段落分割
    echo "$content" | awk -v max_len="$max_length" '
    BEGIN { buffer = ""; count = 0; }
    {
        if (length(buffer) + length($0) + 1 > max_len && buffer != "") {
            print "PART_" ++count;
            print buffer;
            buffer = "";
        }
        buffer = buffer (buffer == "" ? "" : "\n") $0;
    }
    END {
        if (buffer != "") {
            print "PART_" ++count;
            print buffer;
        }
        print "TOTAL_PARTS:" count;
    }'
}

# 5. 发送推送开始通知
echo "📤 开始推送简报到飞书..."
START_MSG="🚀 开始推送每日热点简报 ($DATE $TIME_NOW)
📊 简报信息:
• 文件: $(basename "$LATEST_DIGEST")
• 大小: $FILE_SIZE 字节
• 行数: $LINE_COUNT 行
• 预计分段: $(( (FILE_SIZE / 1500) + 1 )) 部分"

openclaw message send --channel feishu --target "user:ou_4b43037f4903b00868b089beef5cc6d2" \
    --message "$START_MSG" 2>&1 | tee -a "$WORKDIR/digests/push_api.log"

# 6. 分割并发送简报内容
echo "📨 分割并发送简报内容..."
PARTS=$(echo "$DIGEST_CONTENT" | split_digest)

TOTAL_PARTS=0
CURRENT_PART=0
IN_PART=0
PART_CONTENT=""

while IFS= read -r line; do
    if [[ "$line" =~ ^PART_([0-9]+)$ ]]; then
        if [ $IN_PART -eq 1 ]; then
            # 发送上一部分
            echo "📤 发送第 $CURRENT_PART/$TOTAL_PARTS 部分..."
            openclaw message send --channel feishu --target "user:ou_4b43037f4903b00868b089beef5cc6d2" \
                --message "$PART_CONTENT" 2>&1 | tee -a "$WORKDIR/digests/push_api.log"
            sleep 1  # 避免发送过快
        fi
        CURRENT_PART=${BASH_REMATCH[1]}
        IN_PART=1
        PART_CONTENT=""
    elif [[ "$line" =~ ^TOTAL_PARTS:([0-9]+)$ ]]; then
        TOTAL_PARTS=${BASH_REMATCH[1]}
        # 发送最后一部分
        if [ -n "$PART_CONTENT" ]; then
            echo "📤 发送第 $CURRENT_PART/$TOTAL_PARTS 部分..."
            openclaw message send --channel feishu --target "user:ou_4b43037f4903b00868b089beef5cc6d2" \
                --message "$PART_CONTENT" 2>&1 | tee -a "$WORKDIR/digests/push_api.log"
        fi
    elif [ $IN_PART -eq 1 ]; then
        PART_CONTENT="$PART_CONTENT$line\n"
    fi
done <<< "$PARTS"

# 7. 发送推送完成通知
COMPLETE_MSG="✅ 每日热点简报推送完成 ($DATE $TIME_NOW)
📋 推送统计:
• 总部分数: $TOTAL_PARTS
• 文件大小: $FILE_SIZE 字节
• 推送时间: $(date +"%H:%M:%S")
• 下次推送: 明天早上8:00

📁 完整文件: $(basename "$LATEST_DIGEST")
🔧 系统状态: 定时任务运行正常"

openclaw message send --channel feishu --target "user:ou_4b43037f4903b00868b089beef5cc6d2" \
    --message "$COMPLETE_MSG" 2>&1 | tee -a "$WORKDIR/digests/push_api.log"

# 8. 记录推送状态
echo "$(date): 简报推送完成 - $LATEST_DIGEST (共$TOTAL_PARTS部分)" >> "$WORKDIR/digests/push_history.log"

echo "✅ 每日简报推送流程完成"
echo "📊 推送统计:"
echo "  • 文件: $(basename "$LATEST_DIGEST")"
echo "  • 大小: $FILE_SIZE 字节"
echo "  • 部分: $TOTAL_PARTS"
echo "  • 时间: $(date +"%H:%M:%S")"
echo "  • 下次: 明天早上8:00"