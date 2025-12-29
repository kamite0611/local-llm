# Ollama試用環境 計画書

**作成日**: 2025-12-29

---

## 機能概要・目的

Docker Composeを使用してOllamaの動作環境を構築し、ローカルLLMの動作確認を行う。

---

## 実装内容

`./ollama` ディレクトリに以下を作成：

### 1. docker-compose.yml

Ollamaコンテナの定義：
- **イメージ**: `ollama/ollama:latest`
- **ポート**: 11434:11434
- **ボリューム**: モデルデータ永続化（名前付きボリューム）
- **環境変数**:
  - `OLLAMA_NUM_PARALLEL=4` - 並列実行数
  - `OLLAMA_MAX_LOADED_MODELS=3` - 最大ロードモデル数

### 2. README.md

使い方ドキュメント：
- 起動・停止方法
- モデルのダウンロード・実行方法
- 主要コマンド一覧
- API利用例

### 3. Makefile（プロジェクトルートに配置）

便利コマンドをMakefileで提供（`ollama-` プレフィックスで他サービスと区別）：
- `make ollama-up` - コンテナ起動
- `make ollama-down` - コンテナ停止
- `make ollama-logs` - ログ表示
- `make ollama-pull MODEL=<model>` - モデルダウンロード
- `make ollama-run MODEL=<model>` - モデル実行（対話モード）
- `make ollama-list` - ダウンロード済みモデル一覧

※ Makefileはプロジェクトルートに配置し、将来追加するサービス（LM Studioなど）のコマンドも同じファイルで管理

---

## 推奨初期モデル

分析レポートより、以下を最初に試すことを推奨：

| モデル | 予想速度 | メモリ使用量 | 用途 |
|--------|----------|--------------|------|
| `gemma2:7b` | 22-28 t/s | 6-8GB | 軽量・高速、最初のテストに最適 |
| `qwen2.5:8b` | 15-20 t/s | 8-10GB | 日本語対応、汎用 |

---

## タスク分解

1. [ ] `./ollama` ディレクトリ作成
2. [ ] `./ollama/docker-compose.yml` 作成
3. [ ] `./Makefile` 作成（プロジェクトルート）
4. [ ] `./ollama/README.md` 作成
5. [ ] 動作確認
   - コンテナ起動（`make ollama-up`）
   - モデルダウンロード（`make ollama-pull MODEL=gemma2:7b`）
   - 実行テスト（`make ollama-run MODEL=gemma2:7b`）

---

## ディレクトリ構成（完成イメージ）

```
local-llm/
├── Makefile              # プロジェクト共通（ollama-*, 将来は他サービスも追加）
└── ollama/
    ├── docker-compose.yml
    └── README.md
```

---

## 技術的考慮事項

- **ボリューム永続化**: モデルデータは名前付きボリュームで永続化し、コンテナ削除後も再ダウンロード不要
- **ポート**: 11434はOllamaのデフォルトポート、他アプリとの競合に注意
- **メモリ**: 16GB環境では7B-8Bモデルが快適に動作

---

## 備考

- 初回モデルダウンロードは4-5GB程度、時間がかかる
- Dockerが起動していることを事前に確認
