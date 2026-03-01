# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- API keys and credentials
- Anything environment-specific

## API Keys & Credentials

### Tavily Search
- **API Key**: 需要从 https://tavily.com 获取
- **环境变量**: `TAVILY_API_KEY`
- **状态**: 待配置
- **免费额度**: 通常 1000 次搜索/月

### 其他 API
（在此添加其他 API 密钥）

## Search Tools

### Tavily Search 快捷命令
```bash
# 基本搜索
tavily() {
    cd /root/.openclaw/workspace/skills/tavily-search
    node scripts/search.mjs "$1" ${2:+-n $2}
}

# 深度搜索
tavily-deep() {
    cd /root/.openclaw/workspace/skills/tavily-search
    node scripts/search.mjs "$1" --deep ${2:+-n $2}
}

# 新闻搜索
tavily-news() {
    cd /root/.openclaw/workspace/skills/tavily-search
    node scripts/search.mjs "$1" --topic news ${2:+-n $2} ${3:+--days $3}
}
```

使用示例：
```bash
tavily "OpenClaw AI" 5           # 搜索5个结果
tavily-deep "事件驱动交易" 10     # 深度搜索10个结果
tavily-news "区块链" 8 7          # 最近7天的8条区块链新闻
```

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
