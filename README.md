# Local LLM Model Comparison

ローカルLLMモデルの比較検証プロジェクト

## 環境

- Apple M4, 16GB RAM
- macOS
- Ollama (Homebrew)

## セットアップ

```bash
# Ollamaインストール
make install

# サーバー起動（別ターミナルで実行）
make serve
```

## 使い方

```bash
# モデルをダウンロード
make pull MODEL=gemma2

# 対話モードで実行
make run MODEL=gemma2

# ダウンロード済みモデル一覧
make list

# 比較対象モデルを一括ダウンロード
make pull-all
```

## 比較対象モデル

| モデル | サイズ | 特徴 |
|--------|--------|------|
| gemma2 | 9B | Google製、高性能 |
| qwen2.5:7b | 7B | 日本語対応 |
| llama3.2 | 3B | Meta製、軽量 |
| mistral | 7B | 効率的 |

## コマンド一覧

```bash
make help
```
