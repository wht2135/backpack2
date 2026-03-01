#!/bin/bash
# 智能 Tavily 搜索脚本 - 优先使用本地资源，避免浪费免费额度

set -e

QUERY="$1"
PRIORITY="${2:-C}"  # 默认C级（最低优先级）

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 目录设置
CACHE_DIR="/root/.openclaw/workspace/cache/tavily"
LOG_FILE="/root/.openclaw/workspace/logs/tavily_usage.log"
mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# 记录使用日志
log_usage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $PRIORITY | $QUERY" >> "$LOG_FILE"
}

# 显示使用统计
show_stats() {
    TODAY=$(date +%Y-%m-%d)
    TODAY_COUNT=$(grep "^$TODAY" "$LOG_FILE" 2>/dev/null | wc -l || echo 0)
    
    echo -e "${BLUE}📊 使用统计${NC}"
    echo -e "今日: ${GREEN}$TODAY${NC}"
    echo -e "今日使用次数: ${YELLOW}$TODAY_COUNT${NC}"
    
    if [ "$TODAY_COUNT" -ge 15 ]; then
        echo -e "${RED}⚠️  警告：今日使用较多，请谨慎${NC}"
    fi
    echo ""
}

# 检查缓存
check_cache() {
    local cache_file="${CACHE_DIR}/$(echo -n "$QUERY" | md5sum | cut -d' ' -f1).json"
    
    if [ -f "$cache_file" ]; then
        local cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        local max_age=86400  # 24小时
        
        if [ "$cache_age" -lt "$max_age" ]; then
            echo -e "${GREEN}✅ 使用缓存结果（$(($cache_age/3600))小时前）${NC}"
            cat "$cache_file"
            return 0
        else
            echo -e "${YELLOW}📦 缓存过期（$(($cache_age/3600))小时），需要更新${NC}"
        fi
    fi
    return 1
}

# 检查本地文件
check_local() {
    echo -e "${BLUE}🔍 搜索本地文件...${NC}"
    
    # 搜索 memory 目录
    local memory_results=$(grep -r -i "$QUERY" /root/.openclaw/workspace/memory/ 2>/dev/null | head -3)
    
    # 搜索 MEMORY.md
    local main_memory=$(grep -i "$QUERY" /root/.openclaw/workspace/MEMORY.md 2>/dev/null | head -3)
    
    # 搜索 digests 目录
    local digest_results=$(grep -r -i "$QUERY" /root/.openclaw/workspace/digests/ 2>/dev/null | head -3)
    
    if [ -n "$memory_results$main_memory$digest_results" ]; then
        echo -e "${GREEN}✅ 本地找到相关信息${NC}"
        [ -n "$memory_results" ] && echo -e "记忆文件:\n$memory_results"
        [ -n "$main_memory" ] && echo -e "主记忆:\n$main_memory"
        [ -n "$digest_results" ] && echo -e "摘要文件:\n$digest_results"
        return 0
    fi
    
    return 1
}

# 执行 Tavily 搜索
do_tavily_search() {
    local search_type="$1"
    local result_count="$2"
    
    echo -e "${YELLOW}🔎 使用 Tavily 搜索${NC}"
    echo -e "查询: ${GREEN}$QUERY${NC}"
    echo -e "类型: ${BLUE}$search_type${NC}"
    echo -e "数量: ${BLUE}$result_count${NC}"
    
    cd /root/.openclaw/workspace/skills/tavily-search
    
    case "$search_type" in
        "deep")
            node scripts/search.mjs "$QUERY" --deep -n "$result_count"
            ;;
        "news")
            node scripts/search.mjs "$QUERY" --topic news -n "$result_count"
            ;;
        "simple")
            node scripts/search.mjs "$QUERY" -n "$result_count"
            ;;
        *)
            node scripts/search.mjs "$QUERY" -n "$result_count"
            ;;
    esac
    
    # 记录使用
    log_usage
}

# 缓存结果
cache_result() {
    local cache_file="${CACHE_DIR}/$(echo -n "$QUERY" | md5sum | cut -d' ' -f1).json"
    local temp_file="${cache_file}.tmp"
    
    # 执行搜索并缓存
    cd /root/.openclaw/workspace/skills/tavily-search
    node scripts/search.mjs "$QUERY" -n 1 > "$temp_file" 2>/dev/null
    
    if [ -s "$temp_file" ]; then
        mv "$temp_file" "$cache_file"
        echo -e "${GREEN}💾 结果已缓存${NC}"
    else
        rm -f "$temp_file"
    fi
}

# 主逻辑
main() {
    if [ -z "$QUERY" ]; then
        echo -e "${RED}❌ 请提供查询词${NC}"
        echo "用法: $0 \"查询词\" [优先级]"
        echo "优先级: A(紧急) B(重要) C(一般)"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 智能搜索启动${NC}"
    echo -e "查询: ${GREEN}$QUERY${NC}"
    echo -e "优先级: ${YELLOW}$PRIORITY${NC}"
    echo ""
    
    # 显示统计
    show_stats
    
    # 根据优先级处理
    case "$PRIORITY" in
        A|a)
            echo -e "${RED}🚨 A级查询：紧急重要信息${NC}"
            echo -e "${YELLOW}策略：深度搜索 + 新闻搜索${NC}"
            
            if check_cache; then
                exit 0
            fi
            
            if check_local; then
                echo -e "${YELLOW}📝 本地有相关信息，但仍执行深度搜索确保完整性${NC}"
            fi
            
            do_tavily_search "deep" 5
            ;;
            
        B|b)
            echo -e "${YELLOW}📊 B级查询：重要研究信息${NC}"
            echo -e "${BLUE}策略：普通搜索，限制结果数量${NC}"
            
            if check_cache; then
                exit 0
            fi
            
            if check_local; then
                echo -e "${GREEN}✅ 本地找到足够信息，跳过 Tavily 搜索${NC}"
                exit 0
            fi
            
            do_tavily_search "simple" 3
            ;;
            
        C|c)
            echo -e "${BLUE}📝 C级查询：一般信息${NC}"
            echo -e "${GREEN}策略：优先本地资源，最后简单搜索${NC}"
            
            # 1. 检查本地
            if check_local; then
                exit 0
            fi
            
            # 2. 检查缓存
            if check_cache; then
                exit 0
            fi
            
            # 3. 最后使用 Tavily（简单查询）
            echo -e "${YELLOW}⚠️  本地无结果，使用简单搜索${NC}"
            do_tavily_search "simple" 1
            
            # 后台缓存结果
            cache_result &
            ;;
            
        *)
            echo -e "${RED}❌ 无效优先级：$PRIORITY${NC}"
            echo "有效值: A(紧急) B(重要) C(一般)"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ 搜索完成${NC}"
}

# 运行主函数
main "$@"

# 显示最终统计
echo ""
show_stats