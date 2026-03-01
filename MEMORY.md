# MEMORY.md - 长期记忆

## 用户信息
- **身份**：个人交易者
- **关注市场**：A股、美股、区块链
- **交易风格**：事件驱动，关注技术动态和热点新闻
- **沟通偏好**：直接、高效、无废话
- **工作方式**：优先自主解决，确实需要时再询问

## 技术项目记录

### 2026-02-28：v2ray-wss代理服务器部署
**项目概述**：
为用户部署v2ray-wss代理服务器，配置Clash订阅，优化性能。

**技术栈**：
- v2ray (VMess over WebSocket over TLS)
- nginx (反向代理 + TLS终止)
- Let's Encrypt (SSL证书)
- Clash (代理客户端配置)

**配置详情**：
- 域名：vp.itundao.com
- 端口：443 (HTTPS)
- 协议：VMess + WebSocket + TLS
- UUID：920918b2-f6ce-4994-bc6b-ef32428f6e0b
- 路径：/73ea86

**性能数据**：
- 服务器延迟：1.25ms
- 下载速度：256 Mbps
- 上传速度：30 Mbps
- 新加坡节点延迟：2.5-3.1ms

**优化措施**：
1. v2ray配置优化（嗅探、TCP FastOpen）
2. nginx TLS优化（TLS 1.3、现代密码套件）
3. Clash配置合并（多节点冗余）

**订阅链接**：
- https://vp.itundao.com/clash
- https://vp.itundao.com/clashx

**待处理事项**：
1. ✅ 飞书API权限已授权（contact:contact.base:readonly）
2. Cloudflare CDN配置（需注意WebSocket兼容性）
3. 进一步性能调优（BBR拥塞控制等）
4. Tavily API密钥配置（TAVILY_API_KEY）
5. ✅ OpenRouter API密钥已配置（summarize工具测试成功）

## 用户偏好与观察
1. **技术接受度**：高，愿意尝试优化和新技术
2. **配置偏好**：喜欢多节点冗余配置，感觉速度更快
3. **关注点**：新加坡节点性能优化
4. **沟通风格**：直接提问，期待具体解决方案

## 系统状态
- OpenClaw运行正常，有安全警告需修复
- 飞书API权限缺失，影响文件接收功能
- 代理服务稳定运行，性能优秀

## 技能配置记录

### 2026-03-01：技能安装与配置
**已安装技能**：
1. **self-improving-agent** - 自我改进代理技能
   - 功能：记录学习、错误、功能请求
   - 位置：`/root/.openclaw/workspace/skills/self-improving-agent`
   - 状态：✅ 已配置，就绪

2. **tavily-search** - AI优化网络搜索
   - 功能：为AI优化的网络搜索和内容提取
   - 位置：`/root/.openclaw/workspace/skills/tavily-search`
   - 状态：✅ 已配置并测试成功
   - API密钥：`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`
   - 测试结果：所有功能正常工作（基本搜索、新闻搜索、深度搜索）

3. **summarize** - 内容总结工具
   - 功能：URL/文件/YouTube内容总结
   - 位置：`/root/.openclaw/workspace/skills/summarize`
   - 状态：✅ 已配置（OpenRouter API）
   - API密钥：已配置并测试成功

**热点新闻推送问题修复**：
- **问题**：早上8点热点新闻未推送
- **原因**：飞书API权限缺失 + 推送脚本未集成实际API
- **解决**：
  1. ✅ 授权飞书API权限 (contact:contact.base:readonly)
  2. ✅ 创建集成推送脚本 `feishu_push_digest.sh`
  3. ✅ 更新crontab配置
  4. ✅ 测试推送功能成功
- **新配置**：每天早上8点自动推送热点新闻到飞书

**技能系统优化**：
- **审计发现**：11个已安装技能，整体负担低
- **发现冗余**：`tech-news-digest` 与 `summarize` 功能重叠
- **优化行动**：✅ 已移除 `tech-news-digest`
- **待优化**：`notion` 和 `obsidian` 建议二选一保留
- **建议配置**：`tavily-search` 暂不配置，按需启用

**创建的配置工具**：
- `configure_tavily.sh` - Tavily API 配置脚本
- `test_tavily.sh` - Tavily 功能测试脚本
- `quick_test_tavily.sh` - Tavily 快速测试脚本
- `Tavily_API_Setup_Guide.md` - Tavily 完整配置指南（6.1KB）
- `Tavily_Usage_Guide.md` - 详细使用指南
- `feishu_push_digest.sh` - 飞书推送脚本（已集成API）
- `热点新闻推送问题解决方案.md` - 问题分析文档
- `skill_audit.md` - 技能系统审计报告（4.5KB）
- `summarize_quickstart.md` - summarize快速使用指南（3.5KB）
- `OpenRouter_Config_Guide.md` - OpenRouter配置指南（4.5KB）

**TOOLS.md 更新**：
- 添加了 Tavily Search 快捷命令
- 记录了 API 密钥配置状态
- 提供了使用示例

## 经验教训
1. **权限管理**：及时处理API权限问题
2. **配置备份**：重要修改前备份配置文件
3. **性能测试**：优化前后进行对比测试
4. **用户沟通**：明确解释技术选择和影响
5. **技能审计**：定期检查技能冗余和负担
6. **API管理**：集中管理多个API密钥配置

## 2026-03-01 更新
### 新配置完成
1. ✅ **Tavily Search API**：已配置并测试成功
   - API密钥：`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`
   - 功能验证：基本搜索、新闻搜索、深度搜索全部正常
   - 永久配置：已添加到 `~/.bashrc`
   - 智能策略：创建了优先级使用策略和缓存系统

2. ✅ **技能系统优化**：
   - 移除冗余技能：`tech-news-digest`
   - 创建审计报告：`skill_audit.md`
   - 待优化：`notion` 和 `obsidian` 二选一

3. ✅ **完整文档创建**：
   - `tavily_config_test_report.md` - 配置测试报告
   - `Tavily_API_Setup_Guide.md` - 完整配置指南
   - `tavily_usage_priority.md` - 智能使用策略（7.3KB）
   - `smart_tavily_search.sh` - 智能搜索脚本（5.4KB）
   - `summarize_quickstart.md` - 快速使用指南

### 智能使用策略
**核心原则**：优先使用免费资源，Tavily 作为备用方案

**四级优先级**：
1. **本地资源**：搜索本地记忆文件
2. **缓存系统**：24小时缓存查询结果  
3. **替代工具**：agent-browser、web_search等
4. **Tavily Search**：仅当前三层都无法满足时使用

**查询分级**：
- **A级**：紧急重要信息（深度搜索）
- **B级**：重要研究信息（普通搜索）
- **C级**：一般信息查询（优先本地资源）

### 当前系统状态
- **核心技能**：全部配置完成并测试成功
- **API配置**：OpenRouter、Tavily、飞书API全部就绪
- **自动化**：热点新闻推送定时任务已配置
- **优化程度**：技能系统负担低，配置合理

---
*最后更新：2026-03-01 09:54 GMT+8*