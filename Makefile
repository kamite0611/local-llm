# Local LLM Model Comparison - Makefile

# デフォルトモデル
MODEL ?= gemma2

# =============================================================================
# セットアップ
# =============================================================================

.PHONY: install serve

install:
	brew install ollama

serve:
	ollama serve

# =============================================================================
# モデル操作
# =============================================================================

.PHONY: pull run list rm

pull:
	ollama pull $(MODEL)

run:
	ollama run $(MODEL)

list:
	ollama list

rm:
	ollama rm $(MODEL)

# =============================================================================
# モデル比較用（複数モデル一括操作）
# =============================================================================

.PHONY: pull-all compare

# 比較対象モデル（16GBメモリ対応）
MODELS := gemma2 qwen2.5:7b llama3.2 mistral

pull-all:
	@for model in $(MODELS); do \
		echo "=== Pulling $$model ==="; \
		ollama pull $$model; \
	done

# =============================================================================
# ベンチマーク
# =============================================================================

.PHONY: benchmark benchmark-single compare

benchmark:
	@chmod +x benchmark/run_benchmark.sh
	@./benchmark/run_benchmark.sh

benchmark-single:
	@chmod +x benchmark/run_benchmark.sh
	@./benchmark/run_benchmark.sh "$(MODEL)"

compare:
	@chmod +x benchmark/compare_results.sh
	@./benchmark/compare_results.sh

# =============================================================================
# ヘルプ
# =============================================================================

.PHONY: help

help:
	@echo "Local LLM Model Comparison"
	@echo ""
	@echo "セットアップ:"
	@echo "  make install     - Ollamaをインストール (Homebrew)"
	@echo "  make serve       - Ollamaサーバーを起動"
	@echo ""
	@echo "モデル操作:"
	@echo "  make pull MODEL=<model>  - モデルをダウンロード"
	@echo "  make run MODEL=<model>   - モデルを実行（対話モード）"
	@echo "  make list                - ダウンロード済みモデル一覧"
	@echo "  make rm MODEL=<model>    - モデルを削除"
	@echo ""
	@echo "比較用:"
	@echo "  make pull-all    - 比較対象モデルを一括ダウンロード"
	@echo ""
	@echo "ベンチマーク:"
	@echo "  make benchmark           - 全モデルのベンチマーク実行"
	@echo "  make benchmark-single MODEL=<model> - 単一モデルのベンチマーク"
	@echo "  make compare             - 結果を比較表示"
	@echo ""
	@echo "デフォルトモデル: $(MODEL)"
