#!/usr/bin/env python3
"""最终测试OpenTwitter API"""

import sys
import os
import asyncio
sys.path.insert(0, '/root/.openclaw/workspace/opentwitter-mcp/src')

print("🔍 OpenTwitter MCP 安装测试")
print("=" * 60)

try:
    # 1. 测试配置
    from opentwitter_mcp.config import API_BASE_URL, API_TOKEN, MAX_ROWS
    print("✅ 1. 配置加载成功")
    print(f"   • API地址: {API_BASE_URL}")
    print(f"   • Token: {API_TOKEN[:20]}...")
    print(f"   • 最大行数: {MAX_ROWS}")
    
    # 2. 测试API客户端
    from opentwitter_mcp.api_client import TwitterAPIClient
    
    async def test_api():
        print("\n✅ 2. API客户端初始化成功")
        client = TwitterAPIClient()
        
        try:
            # 测试1: 获取用户信息
            print("\n🔍 测试1: 获取VitalikButerin资料")
            user = await client.get_twitter_user_info("VitalikButerin")
            print(f"   ✅ 成功!")
            print(f"     名称: {user.get('name', 'N/A')}")
            print(f"     用户名: {user.get('screenName', 'N/A')}")
            print(f"     粉丝: {user.get('followersCount', 'N/A')}")
            print(f"     描述: {user.get('description', 'N/A')[:80]}...")
            
            # 测试2: 搜索推文
            print("\n🔍 测试2: 搜索Bitcoin相关推文")
            tweets = await client.search_twitter("Bitcoin", limit=2)
            print(f"   ✅ 找到 {len(tweets)} 条推文")
            for i, tweet in enumerate(tweets, 1):
                text = tweet.get('text', '')[:80].replace('\n', ' ')
                likes = tweet.get('favoriteCount', 0)
                retweets = tweet.get('retweetCount', 0)
                print(f"     {i}. {text}... (❤️{likes} 🔄{retweets})")
            
            # 测试3: 获取用户推文
            print("\n🔍 测试3: 获取Elon Musk最新推文")
            user_tweets = await client.get_twitter_user_tweets("elonmusk", limit=2)
            print(f"   ✅ 获取 {len(user_tweets)} 条推文")
            for i, tweet in enumerate(user_tweets, 1):
                text = tweet.get('text', '')[:80].replace('\n', ' ')
                date = tweet.get('createdAt', '')[:10]
                print(f"     {i}. [{date}] {text}...")
            
            return True
            
        except Exception as e:
            print(f"\n❌ API测试失败: {type(e).__name__}: {e}")
            # 检查具体错误
            import traceback
            print("\n详细错误:")
            traceback.print_exc()
            return False
        finally:
            await client.close()
    
    # 运行测试
    print("\n" + "=" * 60)
    print("🚀 开始API测试...")
    success = asyncio.run(test_api())
    
    if success:
        print("\n" + "=" * 60)
        print("🎉 OpenTwitter MCP 安装测试完全通过!")
        print("\n可用功能:")
        print("  • 获取用户资料 (get_twitter_user_info)")
        print("  • 搜索推文 (search_twitter)")
        print("  • 获取用户推文 (get_twitter_user_tweets)")
        print("  • 高级搜索 (search_twitter_advanced)")
        print("  • 关注事件 (get_twitter_follower_events)")
        print("  • 删推数据 (get_twitter_deleted_tweets)")
        print("  • KOL关注者 (get_twitter_kol_followers)")
    else:
        print("\n" + "=" * 60)
        print("⚠️ 测试失败，可能原因:")
        print("  1. Token无效或过期")
        print("  2. 网络连接问题")
        print("  3. API服务暂时不可用")
        print("\n建议:")
        print("  1. 检查token是否正确")
        print("  2. 访问 https://6551.io/mcp 验证token")
        print("  3. 等待几分钟后重试")
        
except Exception as e:
    print(f"\n❌ 初始化失败: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()