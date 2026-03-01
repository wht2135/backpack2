#!/usr/bin/env python3
"""简单测试OpenTwitter API"""

import sys
import os
sys.path.insert(0, '/root/.openclaw/workspace/opentwitter-mcp/src')

try:
    from opentwitter_mcp.config import API_BASE_URL, API_TOKEN, MAX_ROWS
    print("✅ 配置加载成功")
    print(f"   API地址: {API_BASE_URL}")
    print(f"   Token: {API_TOKEN[:20]}...")
    print(f"   最大行数: {MAX_ROWS}")
    
    # 测试API客户端
    from opentwitter_mcp.api_client import TwitterAPIClient
    import asyncio
    
    async def test():
        client = TwitterAPIClient()
        print("\n🔍 测试API连接...")
        
        # 简单请求测试
        try:
            # 测试获取用户
            print("1. 测试获取用户资料...")
            user = await client.get_user("VitalikButerin")
            print(f"   ✅ 成功获取用户: {user.get('name', 'N/A')}")
            print(f"      粉丝数: {user.get('followersCount', 'N/A')}")
            print(f"      推文数: {user.get('statusesCount', 'N/A')}")
            
            # 测试搜索
            print("\n2. 测试搜索推文...")
            tweets = await client.search_tweets("Bitcoin", limit=2)
            print(f"   ✅ 找到 {len(tweets)} 条推文")
            for i, tweet in enumerate(tweets, 1):
                text = tweet.get('text', '')[:60]
                print(f"      {i}. {text}...")
                
            return True
            
        except Exception as e:
            print(f"❌ API请求失败: {e}")
            print(f"   错误类型: {type(e).__name__}")
            return False
    
    # 运行测试
    success = asyncio.run(test())
    if success:
        print("\n🎉 OpenTwitter MCP 测试通过!")
    else:
        print("\n⚠️ 测试失败，请检查token和网络连接")
        
except Exception as e:
    print(f"❌ 初始化失败: {e}")
    import traceback
    traceback.print_exc()