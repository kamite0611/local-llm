#!/bin/bash
# ベンチマーク結果比較スクリプト
# 使い方: ./compare_results.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"

# 色付き出力
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ベンチマーク結果比較${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 最新の結果ファイルを取得
get_latest_results() {
    ls -t "$RESULTS_DIR"/*.json 2>/dev/null | head -10
}

# サマリー表を生成
generate_summary() {
    echo -e "${YELLOW}【総合サマリー】${NC}"
    echo ""
    printf "%-20s %12s %12s %12s\n" "モデル" "平均速度" "総トークン" "メモリ(MB)"
    printf "%-20s %12s %12s %12s\n" "--------------------" "------------" "------------" "------------"

    for file in $(get_latest_results); do
        local model=$(jq -r '.model' "$file")
        local avg_tps=$(jq -r '.summary.avg_tokens_per_sec' "$file")
        local total_tokens=$(jq -r '.summary.total_tokens' "$file")
        local memory=$(jq -r '.memory_mb // "N/A"' "$file")

        printf "%-20s %10s t/s %12s %12s\n" "$model" "$avg_tps" "$total_tokens" "$memory"
    done
    echo ""
}

# カテゴリ別比較
category_comparison() {
    echo -e "${YELLOW}【カテゴリ別速度比較 (tokens/sec)】${NC}"
    echo ""

    local categories=("japanese" "english" "translation" "coding" "reasoning" "summarization" "creative")

    # ヘッダー
    printf "%-15s" "カテゴリ"
    for file in $(get_latest_results); do
        local model=$(jq -r '.model' "$file" | cut -c1-12)
        printf " %12s" "$model"
    done
    echo ""

    printf "%-15s" "---------------"
    for file in $(get_latest_results); do
        printf " %12s" "------------"
    done
    echo ""

    # 各カテゴリ
    for cat in "${categories[@]}"; do
        printf "%-15s" "$cat"
        for file in $(get_latest_results); do
            local avg=$(jq "[.results[] | select(.category == \"$cat\") | .tokens_per_sec] | add / length" "$file" 2>/dev/null)
            if [ "$avg" != "null" ] && [ -n "$avg" ]; then
                printf " %12.1f" "$avg"
            else
                printf " %12s" "N/A"
            fi
        done
        echo ""
    done
    echo ""
}

# ランキング生成
generate_ranking() {
    echo -e "${YELLOW}【速度ランキング】${NC}"
    echo ""

    local rank=1
    for file in $(get_latest_results | xargs -I {} sh -c 'echo "$(jq -r ".summary.avg_tokens_per_sec" {}) {}"' | sort -rn | cut -d' ' -f2-); do
        local model=$(jq -r '.model' "$file")
        local avg_tps=$(jq -r '.summary.avg_tokens_per_sec' "$file")
        echo "  $rank. $model: $avg_tps tokens/sec"
        ((rank++))
    done
    echo ""
}

# 日本語能力ランキング
japanese_ranking() {
    echo -e "${YELLOW}【日本語能力ランキング】${NC}"
    echo ""

    local rank=1
    for line in $(for file in $(get_latest_results); do
        local model=$(jq -r '.model' "$file")
        local jp_avg=$(jq '[.results[] | select(.category == "japanese") | .tokens_per_sec] | add / length' "$file" 2>/dev/null)
        echo "$jp_avg $model"
    done | sort -rn); do
        local tps=$(echo "$line" | cut -d' ' -f1)
        local model=$(echo "$line" | cut -d' ' -f2-)
        if [ "$tps" != "null" ] && [ -n "$tps" ]; then
            echo "  $rank. $model: $tps tokens/sec"
            ((rank++))
        fi
    done
    echo ""
}

# メイン
main() {
    if [ ! -d "$RESULTS_DIR" ] || [ -z "$(ls -A "$RESULTS_DIR" 2>/dev/null)" ]; then
        echo "結果ファイルがありません。"
        echo "先に ./run_benchmark.sh を実行してください。"
        exit 1
    fi

    echo "結果ファイル数: $(ls "$RESULTS_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')"
    echo ""

    generate_summary
    category_comparison
    generate_ranking
    japanese_ranking

    echo -e "${BLUE}========================================${NC}"
    echo "詳細結果: $RESULTS_DIR/"
    echo -e "${BLUE}========================================${NC}"
}

main
