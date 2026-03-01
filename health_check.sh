#!/bin/bash
# OpenClaw 健康检查脚本
# 检查进程状态，异常时自动重启

set -e

LOG_FILE="/root/.openclaw/workspace/logs/health.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "🏥 OpenClaw 健康检查开始: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"

# 检查1：进程是否运行
if ! pgrep -f "openclaw-gateway" > /dev/null; then
    echo "❌ OpenClaw Gateway 进程未运行" | tee -a "$LOG_FILE"
    
    # 尝试重启
    echo "🔄 尝试重启 OpenClaw..." | tee -a "$LOG_FILE"
    
    # 方法1：如果配置了 systemd 服务
    if systemctl is-enabled openclaw.service > /dev/null 2>&1; then
        echo "使用 systemd 重启服务..." | tee -a "$LOG_FILE"
        sudo systemctl restart openclaw.service
        sleep 3
        
        if sudo systemctl is-active openclaw.service > /dev/null 2>&1; then
            echo "✅ 通过 systemd 重启成功" | tee -a "$LOG_FILE"
        else
            echo "❌ systemd 重启失败，尝试直接启动..." | tee -a "$LOG_FILE"
            # 方法2：直接启动进程
            cd /root/.openclaw
            nohup openclaw gateway > /root/.openclaw/logs/gateway_restart.log 2>&1 &
            sleep 2
        fi
    else
        # 方法2：直接启动进程
        echo "直接启动进程..." | tee -a "$LOG_FILE"
        cd /root/.openclaw
        nohup openclaw gateway > /root/.openclaw/logs/gateway_restart.log 2>&1 &
        sleep 2
    fi
    
    # 检查重启结果
    if pgrep -f "openclaw-gateway" > /dev/null; then
        echo "✅ 进程重启成功" | tee -a "$LOG_FILE"
        
        # 发送重启通知（如果配置了飞书）
        if [ -f "/root/.openclaw/workspace/feishu_push_digest.sh" ]; then
            echo "发送重启通知..." | tee -a "$LOG_FILE"
            /root/.openclaw/workspace/feishu_push_digest.sh "🔄 OpenClaw 重启通知" "OpenClaw Gateway 进程异常，已自动重启。时间: $(date '+%Y-%m-%d %H:%M:%S')" > /dev/null 2>&1 &
        fi
    else
        echo "❌ 进程重启失败" | tee -a "$LOG_FILE"
        
        # 发送失败通知
        if [ -f "/root/.openclaw/workspace/feishu_push_digest.sh" ]; then
            echo "发送失败通知..." | tee -a "$LOG_FILE"
            /root/.openclaw/workspace/feishu_push_digest.sh "🚨 OpenClaw 重启失败" "OpenClaw Gateway 进程异常，自动重启失败。需要手动干预。时间: $(date '+%Y-%m-%d %H:%M:%S')" > /dev/null 2>&1 &
        fi
    fi
    
    exit 1
fi

# 检查2：进程运行时间
PROCESS_PID=$(pgrep -f "openclaw-gateway")
if [ -n "$PROCESS_PID" ]; then
    UPTIME=$(ps -o etime= -p "$PROCESS_PID" | xargs)
    echo "✅ 进程运行中 (PID: $PROCESS_PID, 运行时间: $UPTIME)" | tee -a "$LOG_FILE"
    
    # 检查运行时间，如果太短可能是刚重启
    UPTIME_SECONDS=$(ps -o etimes= -p "$PROCESS_PID" | xargs)
    if [ "$UPTIME_SECONDS" -lt 60 ]; then
        echo "⚠️  进程最近重启过 (运行时间: ${UPTIME_SECONDS}秒)" | tee -a "$LOG_FILE"
    fi
fi

# 检查3：内存使用
MEMORY_INFO=$(ps aux | grep openclaw-gateway | grep -v grep | awk '{print "内存: "$4"%, CPU: "$3"%, VSZ: "$5/1024"MB, RSS: "$6/1024"MB"}')
echo "📊 资源使用: $MEMORY_INFO" | tee -a "$LOG_FILE"

# 检查4：端口监听（假设使用3000端口）
if command -v ss > /dev/null; then
    if ss -tlnp | grep -q ":3000"; then
        echo "✅ 端口 3000 监听正常" | tee -a "$LOG_FILE"
    else
        echo "⚠️  端口 3000 未监听" | tee -a "$LOG_FILE"
    fi
elif command -v netstat > /dev/null; then
    if netstat -tlnp | grep -q ":3000"; then
        echo "✅ 端口 3000 监听正常" | tee -a "$LOG_FILE"
    else
        echo "⚠️  端口 3000 未监听" | tee -a "$LOG_FILE"
    fi
fi

# 检查5：简单API测试（如果知道健康检查端点）
# API_URL="http://localhost:3000/health"
# if command -v curl > /dev/null; then
#     if curl -s --max-time 5 "$API_URL" | grep -q "ok"; then
#         echo "✅ API 响应正常" | tee -a "$LOG_FILE"
#     else
#         echo "⚠️  API 响应异常" | tee -a "$LOG_FILE"
#     fi
# fi

echo "✅ 健康检查完成: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "---" | tee -a "$LOG_FILE"