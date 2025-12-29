# CLAUDE.md

## プロジェクト概要

ローカルLLMモデルの比較検証プロジェクト。Ollamaを使用してmacOS上で動作する。

## 環境

- Apple M4, 16GB RAM
- macOS
- Ollama (Homebrew経由)

## よく使うコマンド

```bash
# Ollamaサーバー起動（別ターミナルで）
make serve

# モデルをダウンロード
make pull MODEL=<model>

# モデルを実行（対話モード）
make run MODEL=<model>

# ダウンロード済みモデル一覧
make list

# 比較対象モデルを一括ダウンロード
make pull-all
```

## 比較対象モデル

- gemma2 (9B) - Google製、高性能
- qwen2.5:7b (7B) - 日本語対応
- llama3.2 (3B) - Meta製、軽量
- mistral (7B) - 効率的

## ディレクトリ構成

- `doc/` - ドキュメント・分析結果
- `Makefile` - コマンド定義

## 開発ガイドライン

- 日本語でコメント・ドキュメントを記述する
- 16GBメモリ制約を考慮したモデル選定
