#!/bin/bash
# ローカルLLMベンチマークスクリプト
# 使い方: ./run_benchmark.sh [model_name]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_FILE="$SCRIPT_DIR/prompts.json"
RESULTS_DIR="$SCRIPT_DIR/results"
OLLAMA_API="http://localhost:11434/api/generate"

# デフォルトモデル
MODELS="${1:-gemma2 qwen2.5:7b llama3.2 mistral}"

# 結果ディレクトリ作成
mkdir -p "$RESULTS_DIR"

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ローカルLLMベンチマーク${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Ollamaが起動しているか確認
check_ollama() {
    if ! curl -s "$OLLAMA_API" > /dev/null 2>&1; then
        echo -e "${RED}エラー: Ollamaが起動していません${NC}"
        echo "先に 'make serve' または 'ollama serve' を実行してください"
        exit 1
    fi
    echo -e "${GREEN}✓ Ollama接続確認OK${NC}"
}

# モデルが利用可能か確認
check_model() {
    local model=$1
    if ! ollama list | grep -q "^$model"; then
        echo -e "${YELLOW}警告: $model がインストールされていません。スキップします。${NC}"
        return 1
    fi
    return 0
}

# 単一プロンプトのベンチマーク実行
# 引数: model, prompt_id, prompt, category, output_file
run_single_benchmark() {
    local model=$1
    local prompt_id=$2
    local prompt=$3
    local category=$4
    local output_file=$5

    local start_time=$(python3 -c "import time; print(time.time())")

    # Ollama API呼び出し（ストリーミングOFF）
    local response=$(curl -s "$OLLAMA_API" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$model\",
            \"prompt\": \"$prompt\",
            \"stream\": false
        }" 2>/dev/null)

    local end_time=$(python3 -c "import time; print(time.time())")

    # 結果を解析
    local total_duration=$(echo "$response" | jq -r '.total_duration // 0')
    local eval_count=$(echo "$response" | jq -r '.eval_count // 0')
    local eval_duration=$(echo "$response" | jq -r '.eval_duration // 0')
    local output=$(echo "$response" | jq -r '.response // ""')

    # tokens/sec計算
    local tokens_per_sec=0
    if [ "$eval_duration" -gt 0 ]; then
        tokens_per_sec=$(python3 -c "print(round($eval_count / ($eval_duration / 1e9), 2))")
    fi

    # 経過時間（秒）
    local elapsed=$(python3 -c "print(round($end_time - $start_time, 2))")

    # 出力文字数
    local output_chars=$(echo -n "$output" | wc -c | tr -d ' ')

    # 出力をエスケープしてJSONに含める
    local escaped_output=$(echo "$output" | jq -Rs '.')

    echo "{\"prompt_id\": \"$prompt_id\", \"category\": \"$category\", \"tokens\": $eval_count, \"tokens_per_sec\": $tokens_per_sec, \"elapsed_sec\": $elapsed, \"output_chars\": $output_chars, \"output\": $escaped_output}"
}

# モデルごとのベンチマーク実行
run_model_benchmark() {
    local model=$1
    local result_file="$RESULTS_DIR/${model//[:\/]/_}_$TIMESTAMP.json"

    echo -e "\n${BLUE}=== $model のベンチマーク ===${NC}"

    # モデルをプリロード
    echo -e "${YELLOW}モデルをロード中...${NC}"
    curl -s "$OLLAMA_API" -d "{\"model\": \"$model\", \"prompt\": \"test\", \"stream\": false}" > /dev/null

    # メモリ使用量を取得（macOS）
    local mem_before=$(ps aux | grep -i ollama | grep -v grep | awk '{sum += $6} END {print sum/1024}')

    echo "{" > "$result_file"
    echo "  \"model\": \"$model\"," >> "$result_file"
    echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$result_file"
    echo "  \"memory_mb\": $mem_before," >> "$result_file"
    echo "  \"results\": [" >> "$result_file"

    local first=true
    local total_tokens=0
    local total_time=0

    # 各プロンプトを実行
    local prompt_count=$(jq '.prompts | length' "$PROMPTS_FILE")
    for i in $(seq 0 $((prompt_count - 1))); do
        local prompt_id=$(jq -r ".prompts[$i].id" "$PROMPTS_FILE")
        local prompt_name=$(jq -r ".prompts[$i].name" "$PROMPTS_FILE")
        local prompt=$(jq -r ".prompts[$i].prompt" "$PROMPTS_FILE")
        local category=$(jq -r ".prompts[$i].category" "$PROMPTS_FILE")

        echo -ne "  [$((i+1))/$prompt_count] $prompt_name... "

        local result=$(run_single_benchmark "$model" "$prompt_id" "$prompt" "$category" "$result_file")
        local tokens=$(echo "$result" | jq -r '.tokens')
        local tps=$(echo "$result" | jq -r '.tokens_per_sec')
        local elapsed=$(echo "$result" | jq -r '.elapsed_sec')

        echo -e "${GREEN}${tps} t/s (${elapsed}s)${NC}"

        total_tokens=$((total_tokens + tokens))
        total_time=$(python3 -c "print($total_time + $elapsed)")

        # プロンプト情報と結果を結合
        local escaped_prompt=$(echo "$prompt" | jq -Rs '.')
        local full_result=$(echo "$result" | jq --arg name "$prompt_name" --argjson prompt "$escaped_prompt" '. + {prompt_name: $name, prompt: $prompt}')

        if [ "$first" = true ]; then
            first=false
        else
            echo "    ," >> "$result_file"
        fi
        echo "    $full_result" >> "$result_file"
    done

    echo "" >> "$result_file"
    echo "  ]," >> "$result_file"
    echo "  \"summary\": {" >> "$result_file"
    echo "    \"total_tokens\": $total_tokens," >> "$result_file"
    echo "    \"total_time_sec\": $total_time," >> "$result_file"
    local avg_tps=$(python3 -c "print(round($total_tokens / $total_time, 2) if $total_time > 0 else 0)")
    echo "    \"avg_tokens_per_sec\": $avg_tps" >> "$result_file"
    echo "  }" >> "$result_file"
    echo "}" >> "$result_file"

    echo -e "\n${GREEN}結果保存: $result_file${NC}"
    echo -e "平均速度: ${YELLOW}$avg_tps tokens/sec${NC}"
}

# メイン処理
main() {
    check_ollama

    echo ""
    echo "対象モデル: $MODELS"
    echo "プロンプト数: $(jq '.prompts | length' "$PROMPTS_FILE")"
    echo ""

    for model in $MODELS; do
        if check_model "$model"; then
            run_model_benchmark "$model"
        fi
    done

    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}ベンチマーク完了！${NC}"
    echo -e "結果: $RESULTS_DIR/"
    echo -e "${BLUE}========================================${NC}"
}

main
