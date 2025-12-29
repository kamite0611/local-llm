# Ollama (Docker版)

ローカルLLMランタイム Ollama の Docker Compose 環境

## クイックスタート

```bash
# プロジェクトルートで実行

# 1. コンテナ起動
make ollama-up

# 2. モデルダウンロード
make ollama-pull MODEL=gemma2:7b

# 3. 対話モード開始
make ollama-run MODEL=gemma2:7b
```

## コマンド一覧

| コマンド | 説明 |
|----------|------|
| `make ollama-up` | コンテナ起動 |
| `make ollama-down` | コンテナ停止 |
| `make ollama-logs` | ログ表示 |
| `make ollama-pull MODEL=<model>` | モデルダウンロード |
| `make ollama-run MODEL=<model>` | 対話モード開始 |
| `make ollama-list` | ダウンロード済みモデル一覧 |
| `make ollama-api` | API情報表示 |

## 推奨モデル

| モデル | 予想速度 | メモリ | 用途 |
|--------|----------|--------|------|
| `gemma2:7b` | 22-28 t/s | 6-8GB | 軽量・高速 |
| `qwen2.5:8b` | 15-20 t/s | 8-10GB | 日本語対応 |
| `llama3.2:7b` | 20-25 t/s | 7-9GB | 汎用 |
| `deepseek-coder:7b` | 18-22 t/s | 7-9GB | コーディング |

## API利用

```bash
# 生成API
curl http://localhost:11434/api/generate -d '{
  "model": "gemma2:7b",
  "prompt": "Hello, how are you?"
}'

# ストリーミング無効
curl http://localhost:11434/api/generate -d '{
  "model": "gemma2:7b",
  "prompt": "Hello",
  "stream": false
}'
```

## 設定

`docker-compose.yml` の環境変数:

- `OLLAMA_NUM_PARALLEL=4` - 並列リクエスト数
- `OLLAMA_MAX_LOADED_MODELS=3` - 同時ロードモデル数

## データ永続化

モデルデータは `ollama_data` ボリュームに保存され、コンテナを削除しても保持されます。

```bash
# ボリューム確認
docker volume ls | grep ollama

# ボリューム削除（モデルも削除される）
docker volume rm local-llm_ollama_data
```
