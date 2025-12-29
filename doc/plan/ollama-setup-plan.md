# Ollama モデル比較環境 計画書

**作成日**: 2025-12-29
**更新日**: 2025-12-29

---

## 機能概要・目的

Homebrewを使用してOllamaをインストールし、複数のローカルLLMモデルを比較検証する。

---

## 実装内容

### 1. Makefile

便利コマンドをMakefileで提供：

**セットアップ:**
- `make install` - Ollamaをインストール (Homebrew)
- `make serve` - Ollamaサーバーを起動

**モデル操作:**
- `make pull MODEL=<model>` - モデルダウンロード
- `make run MODEL=<model>` - モデル実行（対話モード）
- `make list` - ダウンロード済みモデル一覧
- `make rm MODEL=<model>` - モデル削除

**比較用:**
- `make pull-all` - 比較対象モデルを一括ダウンロード

### 2. README.md

プロジェクトの使い方ドキュメント

---

## 比較対象モデル

| モデル | 予想速度 | メモリ | 特徴 |
|--------|----------|--------|------|
| gemma2:7b | 22-28 t/s | 6-8GB | 軽量・高速 |
| qwen2.5:8b | 15-20 t/s | 8-10GB | 日本語対応 |
| llama3.2:7b | 20-25 t/s | 7-9GB | 汎用 |
| mistral:7b | 20-25 t/s | 7-9GB | 効率的 |

---

## ディレクトリ構成

```
local-llm/
├── Makefile
├── README.md
└── doc/
    ├── local-llm-analysis.md
    └── plan/
        └── ollama-setup-plan.md
```

---

## 実装状況

- [x] Makefile 作成
- [x] README.md 作成
- [ ] Ollamaインストール (`make install`)
- [ ] モデルダウンロード (`make pull-all`)
- [ ] モデル比較実施
