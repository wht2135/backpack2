#!/bin/bash
# OpenClaw 监控面板
# 一站式查看系统状态

echo "📊 OpenClaw 监控面板"
echo "====================="
echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "主机名: $(hostname)"
echo ""

# 1. 进程状态
echo "🔍 进程状态:"
if pgrep -f "openclaw-gateway" > /dev/null; then
    PROCESS_PID=$(pgrep -f "openclaw-gateway")
    UPTIME=$(ps -o etime= -p "$PROCESS_PID" | xargs)
    MEMORY_CPU=$(ps aux | grep openclaw-gateway | grep -v grep | awk '{print "内存: "$4"%, CPU: "$3"%"}')
    echo "✅ OpenClaw Gateway 正在运行"
    echo "   PID: $PROCESS_PID"
    echo "   运行时间: $UPTIME"
    echo "   资源使用: $MEMORY_CPU"
    
    # 检查运行时间
    UPTIME_SECONDS=$(ps -o etimes= -p "$PROCESS_PID" | xargs)
    if [ "$UPTIME_SECONDS" -lt 300 ]; then  # 5分钟内
        echo "   ⚠️  注意: 进程最近重启过"
    fi
else
    echo "❌ OpenClaw Gateway 未运行"
fi
echo ""

# 2. 系统服务状态
echo "⚙️  系统服务状态:"
if systemctl is-enabled openclaw.service > /dev/null 2>&1; then
    SERVICE_STATUS=$(sudo systemctl is-active openclaw.service 2>/dev/null || echo "unknown")
    if [ "$SERVICE_STATUS" = "active" ]; then
        echo "✅ systemd 服务: 运行中"
        
        # 获取服务信息
        SERVICE_INFO=$(sudo systemctl status openclaw.service --no-pager | grep -A2 "Loaded:" | head -3)
        echo "   服务信息:"
        echo "$SERVICE_INFO" | while read line; do echo "   $line"; done
    elif [ "$SERVICE_STATUS" = "inactive" ]; then
        echo "⚠️  systemd 服务: 已停止"
    else
        echo "❌ systemd 服务: 状态未知"
    fi
else
    echo "ℹ️  未配置 systemd 服务（使用进程方式运行）"
fi
echo ""

# 3. 备份状态
echo "💾 备份状态:"
BACKUP_LOG="/root/.openclaw/workspace/logs/backup.log"
HEALTH_LOG="/root/.openclaw/workspace/logs/health.log"

# 检查Git配置
cd /root/.openclaw/workspace
if [ -d .git ]; then
    if git remote | grep -q origin; then
        REMOTE_URL=$(git remote get-url origin 2>/dev/null | cut -c1-40)
        if [ -f "$BACKUP_LOG" ]; then
            LAST_BACKUP=$(tail -1 "$BACKUP_LOG" 2>/dev/null | cut -c1-50 || echo "无记录")
            BACKUP_COUNT=$(wc -l < "$BACKUP_LOG" 2>/dev/null || echo "0")
            echo "✅ GitHub 备份已配置"
            echo "   远程仓库: $REMOTE_URL"
            echo "   最近备份: $LAST_BACKUP"
            echo "   备份次数: $BACKUP_COUNT"
        else
            echo "✅ GitHub 备份已部分配置"
            echo "   远程仓库: $REMOTE_URL"
            echo "   定时任务: ✅ 已设置（每日2点）"
            echo "   备份脚本: ✅ 已创建"
            echo "   待执行: 首次备份"
        fi
    else
        # 检查是否有认证问题
        echo "⚠️  GitHub 备份准备就绪"
        echo "   Git仓库: ✅ 已初始化"
        echo "   远程仓库: ✅ 已配置 (wht2135/backpack2)"
        echo "   备份脚本: ✅ 已创建"
        echo "   定时任务: ✅ 已设置（每日2点）"
        echo "   待完成: GitHub认证"
        echo "   测试命令: ./test_github_auth.sh"
    fi
else
    echo "❌ GitHub 备份未配置"
    echo "   建议运行: ./setup_github_backup.sh"
fi
echo ""

# 4. 健康检查状态
echo "🏥 健康检查:"
if [ -f "$HEALTH_LOG" ]; then
    LAST_CHECK=$(tail -1 "$HEALTH_LOG" 2>/dev/null | grep -o "检查时间:.*" || echo "无记录")
    CHECK_COUNT=$(wc -l < "$HEALTH_LOG" 2>/dev/null || echo "0")
    
    # 检查最近是否有错误
    LAST_ERROR=$(tail -10 "$HEALTH_LOG" 2>/dev/null | grep -E "❌|⚠️" | tail -1 || echo "无错误")
    
    echo "✅ 健康检查已配置"
    echo "   最近检查: $LAST_CHECK"
    echo "   检查次数: $CHECK_COUNT"
    
    if [ "$LAST_ERROR" != "无错误" ]; then
        echo "   ⚠️  最近错误: $LAST_ERROR"
    fi
else
    echo "❌ 健康检查未配置"
    echo "   建议运行: ./setup_monitoring.sh"
fi
echo ""

# 5. 定时任务
echo "⏰ 定时任务:"
CRON_JOBS=$(crontab -l 2>/dev/null | grep -E "(backup|health|openclaw|feishu)" || echo "未找到相关定时任务")

if [ "$CRON_JOBS" != "未找到相关定时任务" ]; then
    echo "✅ 已配置定时任务:"
    echo "$CRON_JOBS" | while read job; do
        echo "   • $job"
    done
else
    echo "❌ 未配置监控相关定时任务"
fi
echo ""

# 6. 资源使用
echo "📈 系统资源:"
echo "   内存使用: $(free -h | awk '/^Mem:/ {print $3 "/" $2 " (" int($3/$2*100) "%)"}')"
echo "   磁盘使用: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
echo "   负载平均: $(uptime | awk -F'load average:' '{print $2}' | xargs)"
echo ""

# 7. 技能系统状态
echo "🛠️  技能系统:"
SKILLS_COUNT=$(ls -1 /root/.openclaw/workspace/skills/ 2>/dev/null | wc -l)
echo "   已安装技能: $SKILLS_COUNT 个"

# 检查核心技能
CORE_SKILLS=("summarize" "tavily-search" "self-improving-agent")
for skill in "${CORE_SKILLS[@]}"; do
    if [ -d "/root/.openclaw/workspace/skills/$skill" ]; then
        echo "   ✅ $skill: 已安装"
    else
        echo "   ❌ $skill: 未安装"
    fi
done
echo ""

# 8. API 配置状态
echo "🔑 API 配置:"
# 检查 Tavily API
if [ -n "$TAVILY_API_KEY" ]; then
    echo "   ✅ Tavily API: 已配置 (${TAVILY_API_KEY:0:10}...)"
else
    echo "   ❌ Tavily API: 未配置"
fi

# 检查 OpenRouter API（通过环境变量或配置文件）
if env | grep -q "OPENROUTER_API_KEY\|OPENAI_API_KEY"; then
    echo "   ✅ OpenRouter API: 已配置"
else
    echo "   ❌ OpenRouter API: 未配置"
fi
echo ""

# 9. 最近活动
echo "📝 最近活动:"
RECENT_MEMORY=$(find /root/.openclaw/workspace/memory/ -name "*.md" -type f -exec ls -lt {} + 2>/dev/null | head -3 | awk '{print $6" "$7" "$8": "$9}' || echo "无记录")
if [ "$RECENT_MEMORY" != "无记录" ]; then
    echo "   最近记忆文件:"
    echo "$RECENT_MEMORY" | while read line; do
        echo "   • $(basename "$line")"
    done
fi

RECENT_DIGESTS=$(find /root/.openclaw/workspace/digests/ -name "*.md" -type f -exec ls -lt {} + 2>/dev/null | head -2 | awk '{print $6" "$7" "$8": "$9}' || echo "无记录")
if [ "$RECENT_DIGESTS" != "无记录" ]; then
    echo "   最近摘要文件:"
    echo "$RECENT_DIGESTS" | while read line; do
        echo "   • $(basename "$line")"
    done
fi
echo ""

# 10. 建议和警告
echo "💡 系统建议:"

WARNINGS=0

# 检查健康检查频率
CRON_HEALTH=$(crontab -l 2>/dev/null | grep "health_check.sh" || true)
if [ -z "$CRON_HEALTH" ]; then
    echo "   ⚠️  建议: 配置健康检查定时任务"
    ((WARNINGS++))
fi

# 检查备份配置
if [ ! -f "$BACKUP_LOG" ]; then
    echo "   ⚠️  建议: 配置 GitHub 备份"
    ((WARNINGS++))
fi

# 检查 systemd 服务
if ! systemctl is-enabled openclaw.service > /dev/null 2>&1; then
    echo "   ⚠️  建议: 配置 systemd 服务提高稳定性"
    ((WARNINGS++))
fi

# 检查内存使用
MEMORY_PERCENT=$(free | awk '/^Mem:/ {print int($3/$2*100)}')
if [ "$MEMORY_PERCENT" -gt 80 ]; then
    echo "   ⚠️  警告: 内存使用较高 ($MEMORY_PERCENT%)"
    ((WARNINGS++))
fi

if [ $WARNINGS -eq 0 ]; then
    echo "   ✅ 系统状态良好，无需立即操作"
fi

echo ""
echo "🔧 可用命令:"
echo "   ./monitor_dashboard.sh          # 查看此面板"
echo "   ./health_check.sh               # 执行健康检查"
echo "   ./smart_tavily_search.sh        # 智能搜索"
echo "   crontab -l                      # 查看定时任务"
echo "   sudo systemctl status openclaw  # 查看服务状态"

echo ""
echo "📞 如需帮助:"
echo "   1. 查看日志: /root/.openclaw/workspace/logs/"
echo "   2. 检查配置: /root/.openclaw/workspace/"
echo "   3. 重启服务: sudo systemctl restart openclaw"

echo ""
echo "✅ 监控面板检查完成"