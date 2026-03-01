# 系统监控与备份解决方案

## 📋 问题分析

### 当前状态检查

#### 1. GitHub 备份状态 ❌
- **Git 仓库**：已初始化，但未提交
- **远程仓库**：未配置
- **定时备份**：未设置
- **备份内容**：workspace 目录未纳入版本控制

#### 2. 程序监控状态 ⚠️
- **OpenClaw Gateway**：正在运行（进程ID: 314802）
- **系统服务**：未配置为 systemd 服务
- **自动重启**：未配置监控和重启机制
- **健康检查**：无定期健康检查

## 🚀 解决方案

### 第一部分：GitHub 定时备份

#### 步骤1：配置 GitHub 仓库
```bash
# 1. 初始化 Git（如果未初始化）
cd /root/.openclaw/workspace
git init

# 2. 配置用户信息
git config user.email "your-email@example.com"
git config user.name "Your Name"

# 3. 添加远程仓库（需要先创建GitHub仓库）
git remote add origin https://github.com/yourusername/openclaw-workspace.git

# 4. 创建 .gitignore 文件
cat > .gitignore << 'EOF'
# 忽略敏感文件
*.key
*.pem
*.env
.secrets/
.secret/

# 忽略缓存和日志
cache/
logs/
*.log
*.tmp
*.temp

# 忽略 node_modules
node_modules/

# 忽略技能目录（可选，因为技能可以通过clawhub重新安装）
skills/*

# 忽略系统文件
.openclaw/
.clawhub/
EOF

# 5. 添加并提交文件
git add .
git commit -m "Initial commit: OpenClaw workspace backup"

# 6. 推送到远程仓库
git push -u origin master
```

#### 步骤2：创建自动备份脚本
```bash
#!/bin/bash
# /root/.openclaw/workspace/backup_to_github.sh

set -e

echo "🚀 开始 GitHub 备份 $(date)"

# 进入工作目录
cd /root/.openclaw/workspace

# 检查 Git 状态
if [ ! -d .git ]; then
    echo "❌ Git 仓库未初始化"
    exit 1
fi

# 检查远程仓库
if ! git remote | grep -q origin; then
    echo "❌ 未配置远程仓库"
    exit 1
fi

# 拉取最新更改（避免冲突）
echo "📥 拉取最新更改..."
git pull origin master --rebase --autostash

# 添加所有更改
echo "📝 添加更改..."
git add .

# 检查是否有更改
if git diff --cached --quiet; then
    echo "✅ 没有需要提交的更改"
    exit 0
fi

# 提交更改
COMMIT_MSG="Backup: $(date '+%Y-%m-%d %H:%M:%S') - $(hostname)"
echo "💾 提交更改: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# 推送到 GitHub
echo "🚀 推送到 GitHub..."
git push origin master

echo "✅ 备份完成 $(date)"

# 记录备份日志
echo "$(date): GitHub backup completed" >> /root/.openclaw/workspace/logs/backup.log
```

#### 步骤3：设置定时备份
```bash
# 1. 给脚本执行权限
chmod +x /root/.openclaw/workspace/backup_to_github.sh

# 2. 添加到 crontab（每天凌晨2点备份）
(crontab -l 2>/dev/null; echo "0 2 * * * /root/.openclaw/workspace/backup_to_github.sh >> /root/.openclaw/workspace/logs/cron_backup.log 2>&1") | crontab -

# 3. 也可以设置每小时备份（更频繁）
# (crontab -l 2>/dev/null; echo "0 * * * * /root/.openclaw/workspace/backup_to_github.sh >> /root/.openclaw/workspace/logs/cron_backup_hourly.log 2>&1") | crontab -
```

#### 步骤4：创建备份策略
```bash
#!/bin/bash
# /root/.openclaw/workspace/backup_strategy.sh

# 备份频率策略：
# 1. 每日完整备份（凌晨2点）
# 2. 重要文件实时监控（通过Git钩子）
# 3. 手动触发备份（当有重要更改时）

# 重要文件监控
IMPORTANT_FILES=(
    "MEMORY.md"
    "memory/*.md"
    "digests/*.md"
    "TOOLS.md"
    "USER.md"
    "IDENTITY.md"
    "SOUL.md"
)

# Git 提交后钩子（自动推送）
cat > /root/.openclaw/workspace/.git/hooks/post-commit << 'EOF'
#!/bin/bash
# 提交后自动推送（可选）
echo "🔄 自动推送更改到远程仓库..."
git push origin master
EOF
chmod +x /root/.openclaw/workspace/.git/hooks/post-commit
```

### 第二部分：程序监控与自动重启

#### 步骤1：创建 systemd 服务
```bash
# /etc/systemd/system/openclaw.service

[Unit]
Description=OpenClaw AI Assistant Gateway
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=10
User=root
WorkingDirectory=/root/.openclaw
ExecStart=/usr/bin/openclaw gateway
Environment="NODE_ENV=production"
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

# 资源限制（可选）
# MemoryLimit=512M
# CPUQuota=50%

[Install]
WantedBy=multi-user.target
```

#### 步骤2：启用和启动服务
```bash
# 1. 创建服务文件
sudo tee /etc/systemd/system/openclaw.service > /dev/null << 'EOF'
[Unit]
Description=OpenClaw AI Assistant Gateway
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=10
User=root
WorkingDirectory=/root/.openclaw
ExecStart=/usr/bin/openclaw gateway
Environment="NODE_ENV=production"
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

[Install]
WantedBy=multi-user.target
EOF

# 2. 重新加载 systemd
sudo systemctl daemon-reload

# 3. 启用服务（开机自启）
sudo systemctl enable openclaw.service

# 4. 启动服务
sudo systemctl start openclaw.service

# 5. 检查状态
sudo systemctl status openclaw.service
```

#### 步骤3：创建健康检查脚本
```bash
#!/bin/bash
# /root/.openclaw/workspace/health_check.sh

set -e

echo "🏥 OpenClaw 健康检查 $(date)"

# 检查1：进程是否运行
if ! pgrep -f "openclaw-gateway" > /dev/null; then
    echo "❌ OpenClaw Gateway 进程未运行"
    
    # 尝试重启
    echo "🔄 尝试重启 OpenClaw..."
    
    # 如果配置了 systemd 服务
    if systemctl is-enabled openclaw.service > /dev/null 2>&1; then
        sudo systemctl restart openclaw.service
        echo "✅ 通过 systemd 重启服务"
    else
        # 直接启动进程
        cd /root/.openclaw
        nohup openclaw gateway > /root/.openclaw/logs/gateway.log 2>&1 &
        echo "✅ 直接启动进程"
    fi
    
    # 发送通知（如果配置了飞书）
    if [ -f "/root/.openclaw/workspace/feishu_push_digest.sh" ]; then
        /root/.openclaw/workspace/feishu_push_digest.sh "🚨 OpenClaw 重启通知" "OpenClaw Gateway 进程异常，已自动重启。时间: $(date)" > /dev/null 2>&1 &
    fi
    
    exit 1
fi

# 检查2：API 是否响应
API_URL="http://localhost:3000/health"  # 假设 OpenClaw 有健康检查端点
if command -v curl > /dev/null; then
    if ! curl -s --max-time 5 "$API_URL" | grep -q "ok"; then
        echo "⚠️  API 响应异常"
        # 可以记录日志或发送警告
    else
        echo "✅ API 响应正常"
    fi
fi

# 检查3：内存使用
MEMORY_USAGE=$(ps aux | grep openclaw-gateway | grep -v grep | awk '{print $4}')
echo "📊 内存使用: ${MEMORY_USAGE}%"

# 检查4：运行时间
UPTIME=$(ps -o etime= -p $(pgrep -f "openclaw-gateway") | xargs)
echo "⏱️  运行时间: $UPTIME"

echo "✅ 健康检查完成"

# 记录检查日志
echo "$(date): Health check passed" >> /root/.openclaw/workspace/logs/health.log
```

#### 步骤4：设置定时健康检查
```bash
# 1. 给脚本执行权限
chmod +x /root/.openclaw/workspace/health_check.sh

# 2. 添加到 crontab（每5分钟检查一次）
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/.openclaw/workspace/health_check.sh >> /root/.openclaw/workspace/logs/cron_health.log 2>&1") | crontab -

# 3. 也可以设置更频繁的检查（每1分钟）
# (crontab -l 2>/dev/null; echo "*/1 * * * * /root/.openclaw/workspace/health_check.sh >> /root/.openclaw/workspace/logs/cron_health_minute.log 2>&1") | crontab -
```

#### 步骤5：创建监控面板脚本
```bash
#!/bin/bash
# /root/.openclaw/workspace/monitor_dashboard.sh

echo "📊 OpenClaw 监控面板"
echo "====================="
echo "检查时间: $(date)"
echo ""

# 1. 进程状态
echo "🔍 进程状态:"
if pgrep -f "openclaw-gateway" > /dev/null; then
    echo "✅ OpenClaw Gateway 正在运行"
    ps aux | grep openclaw-gateway | grep -v grep
else
    echo "❌ OpenClaw Gateway 未运行"
fi
echo ""

# 2. 系统服务状态
echo "⚙️  系统服务状态:"
if systemctl is-enabled openclaw.service > /dev/null 2>&1; then
    sudo systemctl status openclaw.service --no-pager | head -10
else
    echo "⚠️  未配置 systemd 服务"
fi
echo ""

# 3. 备份状态
echo "💾 备份状态:"
if [ -f "/root/.openclaw/workspace/logs/backup.log" ]; then
    echo "最近备份: $(tail -1 /root/.openclaw/workspace/logs/backup.log 2>/dev/null || echo '无记录')"
else
    echo "❌ 备份日志不存在"
fi
echo ""

# 4. 健康检查日志
echo "🏥 健康检查:"
if [ -f "/root/.openclaw/workspace/logs/health.log" ]; then
    echo "最近检查: $(tail -1 /root/.openclaw/workspace/logs/health.log 2>/dev/null || echo '无记录')"
else
    echo "⚠️  健康检查日志不存在"
fi
echo ""

# 5. 资源使用
echo "📈 资源使用:"
echo "内存: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "磁盘: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
echo ""

# 6. 定时任务
echo "⏰ 定时任务:"
crontab -l 2>/dev/null | grep -E "(backup|health|openclaw)" || echo "未找到相关定时任务"
```

## 🔧 实施步骤

### 第一阶段：立即实施（基础监控）
```bash
# 1. 创建必要的目录
mkdir -p /root/.openclaw/workspace/logs
mkdir -p /root/.openclaw/workspace/cache

# 2. 创建健康检查脚本
创建 /root/.openclaw/workspace/health_check.sh

# 3. 设置定时检查（每5分钟）
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/.openclaw/workspace/health_check.sh >> /root/.openclaw/workspace/logs/cron_health.log 2>&1") | crontab -

# 4. 创建监控面板
创建 /root/.openclaw/workspace/monitor_dashboard.sh
chmod +x /root/.openclaw/workspace/monitor_dashboard.sh
```

### 第二阶段：GitHub 备份配置
```bash
# 1. 配置 GitHub 仓库（需要你先创建仓库）
# 2. 创建备份脚本
创建 /root/.openclaw/workspace/backup_to_github.sh

# 3. 设置每日备份
(crontab -l 2>/dev/null; echo "0 2 * * * /root/.openclaw/workspace/backup_to_github.sh >> /root/.openclaw/workspace/logs/cron_backup.log 2>&1") | crontab -
```

### 第三阶段：系统服务化（高级）
```bash
# 1. 创建 systemd 服务文件
sudo tee /etc/systemd/system/openclaw.service

# 2. 启用和启动服务
sudo systemctl daemon-reload
sudo systemctl enable openclaw.service
sudo systemctl start openclaw.service
```

## 📊 监控指标

### 关键性能指标（KPI）
1. **可用性**：进程运行时间 > 99%
2. **响应时间**：API 响应 < 1秒
3. **资源使用**：内存 < 80%，CPU < 70%
4. **备份完整性**：每日备份成功率 > 95%

### 报警阈值
- **严重**：进程停止 > 1分钟
- **警告**：内存使用 > 80%
- **提醒**：备份失败 > 2次

## 🚨 故障处理流程

### 自动恢复流程
```
检测到故障 → 记录日志 → 尝试重启 → 检查状态 → 发送通知
```

### 手动干预流程
```
收到报警 → 查看监控面板 → 分析日志 → 执行修复 → 验证恢复
```

## 📋 检查清单

### 每日检查
- [ ] 进程运行状态
- [ ] 备份执行情况
- [ ] 资源使用情况
- [ ] 错误日志分析

### 每周检查
- [ ] 备份完整性验证
- [ ] 日志文件清理
- [ ] 系统更新检查
- [ ] 配置备份验证

### 每月检查
- [ ] 监控策略评估
- [ ] 性能趋势分析
- [ ] 安全审计
- [ ] 灾难恢复测试

## ✅ 预期效果

### 可靠性提升
- **自动重启**：进程异常时自动恢复
- **健康监控**：定期检查系统状态
- **预警机制**：问题早期发现和处理

### 数据安全
- **定期备份**：重要数据自动备份到 GitHub
- **版本控制**：所有更改可追溯
- **灾难恢复**：系统崩溃时可快速恢复

### 运维效率
- **集中监控**：一站式查看所有状态
- **自动化运维**：减少手动干预
- **透明管理**：所有操作有记录可查

## 🎯 实施优先级

### 高优先级（立即实施）
1. ✅ 健康检查脚本
2. ✅ 定时监控任务
3. ✅ 基础日志系统

### 中优先级（本周内）
1. 🔄 GitHub 备份配置
2. 🔄 监控面板完善
3. 🔄 报警通知集成

### 低优先级（本月内）
1. ⏳ systemd 服务化
2. ⏳ 高级监控指标
3. ⏳ 自动化测试

**通过这套系统，可以确保 OpenClaw 的高可用性和数据安全性。** 🛡️