#!/usr/bin/env python3
"""测试OpenTwitter MCP功能"""

import os
import sys
import json
import asyncio
from opentwitter_mcp.api_client import TwitterAPIClient

# 设置token
os.environ['TWITTER_TOKEN'] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiN01nM0F4VEYySmdpZEhZNm1xQVR4VVRSSzJRaFNiaEtxaGZCMXJ4WGcxY1QiLCJub25jZSI6ImQzZWZkYmZlLWI2Y2MtNDI3MS05Nzk4LWU3ZDg5MmE5NDAwOSIsImlhdCI6MTc3MjI1NzgxMSwianRpIjoiZmFhMjliMWYtMTFjYi00YWFmLTlmMWMtYTVkNmRlODZlNjQzIn0.X0IzDW87rXV_7UK6x6lY8eaM47Qws_hI5LiaHftWnn8"

async def test_twitter():
    """测试Twitter API功能"""
    print("🔍 测试OpenTwitter MCP功能")
    print("=" * 50)
    
    try:
        # 创建API客户端
        client = TwitterAPIClient()
        
        # 测试1: 获取用户资料
        print("1. 测试获取用户资料...")
        try:
            user = await client.get_user("VitalikButerin")
            print(f"   ✅ VitalikButerin资料:")
            print(f"      名称: {user.get('name', 'N/A')}")
            print(f"      粉丝: {user.get('followersCount', 'N/A')}")
            print(f"      推文: {user.get('statusesCount', 'N/A')}")
        except Exception as e:
            print(f"   ❌ 获取用户资料失败: {e}")
        
        print("\n2. 测试搜索推文...")
        try:
            tweets = await client.search_tweets("Bitcoin", limit=3)
            print(f"   ✅ 找到 {len(tweets)} 条Bitcoin相关推文")
            for i, tweet in enumerate(tweets[:2], 1):
                print(f"      {i}. {tweet.get('text', '')[:80]}...")
        except Exception as e:
            print(f"   ❌ 搜索推文失败: {e}")
        
        print("\n3. 测试获取用户推文...")
        try:
            user_tweets = await client.get_user_tweets("elonmusk", limit=2)
            print(f"   ✅ 获取到 {len(user_tweets)} 条Elon Musk推文")
            for i, tweet in enumerate(user_tweets, 1):
                print(f"      {i}. {tweet.get('text', '')[:80]}...")
        except Exception as e:
            print(f"   ❌ 获取用户推文失败: {e}")
            
    except Exception as e:
        print(f"❌ 初始化客户端失败: {e}")
        return False
    
    print("\n" + "=" * 50)
    print("✅ 测试完成!")
    return True

if __name__ == "__main__":
    # 运行测试
    success = asyncio.run(test_twitter())
    sys.exit(0 if success else 1)