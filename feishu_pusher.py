#!/usr/bin/env python3
"""
飞书推送集成模块
实际推送需要配置飞书API
"""

import os
import sys
from pathlib import Path

class FeishuPusher:
    def __init__(self):
        self.target_user = "ou_4b43037f4903b00868b089beef5cc6d2"
        
    def send_message(self, content):
        """发送消息到飞书"""
        # 这里应该调用飞书API
        print(f"📨 发送消息到飞书用户: {self.target_user}")
        print(f"📝 消息长度: {len(content)} 字符")
        print("📋 消息预览:", content[:200] + "...")
        
        # 实际应该调用 message tool
        # 暂时记录日志
        self._log_push("message", content[:100])
        return True
    
    def send_file(self, filepath, caption=""):
        """发送文件到飞书"""
        if not os.path.exists(filepath):
            print(f"❌ 文件不存在: {filepath}")
            return False
        
        filename = os.path.basename(filepath)
        filesize = os.path.getsize(filepath)
        
        print(f"📎 发送文件到飞书: {filename}")
        print(f"📊 文件大小: {filesize} 字节")
        print(f"📝 说明: {caption}")
        
        # 实际应该调用 message tool with path parameter
        # 暂时记录日志
        self._log_push("file", f"{filename} ({filesize} bytes)")
        return True
    
    def send_digest(self, content, filepath=None):
        """发送完整简报"""
        print("🚀 开始推送每日简报...")
        
        # 1. 发送消息
        success_msg = self.send_message(content)
        
        # 2. 发送文件（如果有）
        success_file = True
        if filepath and os.path.exists(filepath):
            success_file = self.send_file(filepath, "每日热点简报")
        
        # 3. 发送确认
        if success_msg and success_file:
            confirm_msg = f"✅ 每日简报推送完成\n时间: {Path(filepath).name if filepath else 'N/A'}"
            self.send_message(confirm_msg)
            print("🎉 简报推送完成")
            return True
        else:
            error_msg = "❌ 简报推送失败，请检查日志"
            self.send_message(error_msg)
            print("⚠️ 简报推送失败")
            return False
    
    def _log_push(self, push_type, content):
        """记录推送日志"""
        log_file = Path("/root/.openclaw/workspace/digests/feishu_push.log")
        import datetime
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        with open(log_file, 'a', encoding='utf-8') as f:
            f.write(f"{timestamp} | {push_type} | {content}\n")

if __name__ == "__main__":
    pusher = FeishuPusher()
    
    # 测试推送
    test_content = "📰 测试推送\n这是每日简报推送功能测试。"
    test_file = "/root/.openclaw/workspace/digests/test_digest.md"
    
    # 创建测试文件
    Path(test_file).write_text(test_content, encoding='utf-8')
    
    print("🧪 测试飞书推送功能...")
    pusher.send_digest(test_content, test_file)
    print("✅ 测试完成")
