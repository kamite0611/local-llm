# ローカルLLM分析レポート (2025年版)

**作成日**: 2025年12月29日
**対象環境**: Apple M4, 16GB RAM, macOS 26.1

---

## 🖥️ システム環境

- **チップ**: Apple M4
- **メモリ**: 16GB
- **OS**: macOS 26.1 (25B78)
- **Docker**: インストール済み (v28.5.1)
- **メモリ帯域幅**: 273GB/s (推定)

**結論**: 7B〜13Bクラスのモデルを快適に実行可能。一部14B〜32Bモデルも動作可能。

---

## 🎯 推奨ツール比較

### 1. Ollama

**概要**: CLI型のローカルLLMランタイム

**特徴**:
- 完全無料・オープンソース (MIT License)
- コマンドラインインターフェース
- 軽量・高速なモデル読み込み
- Docker公式イメージ提供
- Linux/macOS/Windows対応
- REST API提供

**向いている人**:
- 開発者
- 自動化・スクリプト組み込みを考えている人
- CLI操作に慣れている人
- プライバシーを重視する人

**パフォーマンス**:
- 軽量設計で高速なモデル読み込み
- 低メモリオーバーヘッド
- Modelfile最適化対応

**Docker対応**: ✅ 公式Dockerイメージあり

### 2. LM Studio

**概要**: GUI型のローカルLLMプラットフォーム

**特徴**:
- グラフィカルユーザーインターフェース
- 1000+以上の事前設定済みモデルライブラリ
- MLX対応 (Apple Silicon最適化)
- モデル検索・ダウンロード・チャット機能統合
- Windows/macOS対応
- クローズドソース

**向いている人**:
- 初心者
- GUIを好む人
- 教育・学習目的
- プロンプトテストを頻繁に行う人

**パフォーマンス**:
- MLXモデルはOllamaより高速・省メモリ (macOS)
- 安定したパフォーマンス
- シングルモデル操作に最適化

**Docker対応**: ❌ GUI型のためDocker非対応

### 比較表

| 項目 | Ollama | LM Studio |
|------|--------|-----------|
| インターフェース | CLI | GUI |
| ライセンス | MIT (OSS) | クローズドソース |
| プラットフォーム | Linux/macOS/Windows | macOS/Windows |
| Docker対応 | ✅ | ❌ |
| API提供 | ✅ | ✅ |
| macOSでの速度 | 高速 | より高速(MLX) |
| メモリ効率 | 良好 | より良好(MLX) |
| 学習曲線 | やや急 | 緩やか |
| 自動化 | ✅ 容易 | 制限的 |

---

## 🤖 推奨モデル (16GBメモリ環境)

### 汎用・会話向けモデル

#### Qwen 2.5 8B
- **特徴**: 2025年最新の高性能モデル
- **メモリ要件**: 約8-10GB
- **予想速度**: 15-20 tokens/秒 (M4)
- **得意分野**: 汎用タスク、多言語対応、日本語
- **Ollama**: `qwen2.5:8b`

#### Llama 3.2 7B
- **特徴**: Meta製、バランスの良いモデル
- **メモリ要件**: 約7-9GB
- **予想速度**: 20-25 tokens/秒 (M4)
- **得意分野**: 汎用タスク、会話
- **Ollama**: `llama3.2:7b`

#### Mistral 7B
- **特徴**: 軽量ながら高性能
- **メモリ要件**: 約7-9GB
- **予想速度**: 20-25 tokens/秒 (M4)
- **得意分野**: 汎用タスク、効率性
- **Ollama**: `mistral:7b`

### コーディング特化モデル

#### DeepSeek-Coder 7B
- **特徴**: コード生成に特化した最新モデル
- **メモリ要件**: 約7-9GB
- **予想速度**: 18-22 tokens/秒 (M4)
- **得意分野**: コード生成、デバッグ、リファクタリング
- **Ollama**: `deepseek-coder:7b`

#### CodeLlama 7B
- **特徴**: Meta製のコーディング特化型
- **メモリ要件**: 約7-9GB
- **予想速度**: 18-22 tokens/秒 (M4)
- **得意分野**: コード生成、説明
- **Ollama**: `codellama:7b`

### 軽量・高速モデル

#### Gemma 2 7B
- **特徴**: Google製、効率的な設計
- **メモリ要件**: 約6-8GB
- **予想速度**: 22-28 tokens/秒 (M4)
- **得意分野**: 高速応答、リソース効率
- **Ollama**: `gemma2:7b`

#### TinyLlama 1.1B
- **特徴**: 超軽量モデル
- **メモリ要件**: 約1-2GB
- **予想速度**: 50+ tokens/秒 (M4)
- **得意分野**: 制約環境、高速応答
- **Ollama**: `tinyllama:1.1b`

### より大きなモデル (メモリぎりぎり)

#### Qwen 2.5 14B
- **特徴**: より高性能な中規模モデル
- **メモリ要件**: 約12-14GB (4bit量子化)
- **予想速度**: 10-15 tokens/秒 (M4)
- **得意分野**: 複雑な推論、日本語
- **Ollama**: `qwen2.5:14b`
- **注意**: 16GBでは他アプリを閉じる必要あり

### メモリ要件の目安

- **7Bモデル**: 最低8GB RAM推奨
- **13Bモデル**: 最低16GB RAM推奨
- **33Bモデル**: 最低32GB RAM推奨

---

## 🚀 セットアップガイド

### Ollama (Docker版)

#### 基本セットアップ

```bash
# Ollamaコンテナを起動
docker run -d \
  -v ollama:/root/.ollama \
  -p 11434:11434 \
  --name ollama \
  ollama/ollama

# モデルをダウンロード&実行
docker exec -it ollama ollama run qwen2.5:8b
```

#### Docker Compose版

`docker-compose.yml`を作成:

```yaml
version: '3.8'
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama
    environment:
      - OLLAMA_NUM_PARALLEL=4
      - OLLAMA_MAX_LOADED_MODELS=3

volumes:
  ollama:
```

起動:

```bash
docker-compose up -d
docker exec -it ollama ollama run qwen2.5:8b
```

#### 主要コマンド

```bash
# モデル一覧
docker exec -it ollama ollama list

# モデルダウンロード
docker exec -it ollama ollama pull llama3.2:7b

# モデル実行
docker exec -it ollama ollama run llama3.2:7b

# モデル削除
docker exec -it ollama ollama rm llama3.2:7b

# API経由で実行
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:8b",
  "prompt": "日本語で自己紹介してください"
}'
```

### LM Studio

#### インストール

1. 公式サイトからダウンロード: https://lmstudio.ai/
2. macOS版をインストール
3. 起動してモデルライブラリを参照

#### 推奨設定 (M4向け)

- **MLXモデルを優先**: メモリ効率が良い
- **コンテキスト長**: 4096-8192が安定
- **スレッド数**: 8-10 (M4のコア数に応じて)

---

## 📊 M4パフォーマンス予測

### ベンチマーク予測 (Apple M4, 16GB)

| モデル | 予想速度 | メモリ使用量 | 推奨度 |
|--------|----------|--------------|--------|
| TinyLlama 1.1B | 50+ t/s | 1-2GB | ⭐⭐⭐ |
| Gemma 2 7B | 22-28 t/s | 6-8GB | ⭐⭐⭐⭐⭐ |
| Llama 3.2 7B | 20-25 t/s | 7-9GB | ⭐⭐⭐⭐⭐ |
| Mistral 7B | 20-25 t/s | 7-9GB | ⭐⭐⭐⭐⭐ |
| Qwen 2.5 8B | 15-20 t/s | 8-10GB | ⭐⭐⭐⭐⭐ |
| DeepSeek-Coder 7B | 18-22 t/s | 7-9GB | ⭐⭐⭐⭐ |
| Qwen 2.5 14B | 10-15 t/s | 12-14GB | ⭐⭐⭐ |

**t/s**: tokens per second (トークン/秒)

### M4の優位性

- **統合メモリアーキテクチャ**: CPU/GPU間のデータ転送が不要
- **高速メモリ帯域**: 273GB/s
- **MLXフレームワーク**: Apple Silicon最適化
- **省電力**: 高性能ながら低消費電力

---

## 💡 使い分けの推奨

### Ollamaを選ぶべきケース

- Docker環境で動かしたい
- CLI操作に慣れている
- スクリプトや自動化に組み込みたい
- 開発環境の一部として使いたい
- プライバシー重視 (オープンソース)
- Linux環境でも使いたい

### LM Studioを選ぶべきケース

- 初めてローカルLLMを試す
- GUIで簡単に操作したい
- プロンプトのテストを頻繁に行う
- モデルを簡単に切り替えたい
- macOSで最高のパフォーマンスが欲しい (MLX)
- オフラインでの教育・学習目的

### 両方使う

実際には両方インストールして使い分けるのも良い選択肢:

- **開発・自動化**: Ollama
- **対話・テスト**: LM Studio

---

## 🔧 パフォーマンス最適化のヒント

### Ollama

```bash
# 並列実行数を調整
export OLLAMA_NUM_PARALLEL=4

# 最大ロードモデル数
export OLLAMA_MAX_LOADED_MODELS=3

# コンテキスト長を調整
ollama run qwen2.5:8b --ctx-size 4096
```

### 一般的なヒント

1. **不要なアプリを閉じる**: メモリを確保
2. **適切なモデルサイズを選ぶ**: 16GBなら7B-13Bが最適
3. **量子化モデルを使う**: 4bit量子化でメモリ削減
4. **コンテキスト長を調整**: 長すぎるとメモリ不足に

---

## 📚 参考リソース

### 公式ドキュメント

- **Ollama**: https://ollama.ai/
- **Ollama GitHub**: https://github.com/ollama/ollama
- **LM Studio**: https://lmstudio.ai/
- **MLX (Apple)**: https://github.com/ml-explore/mlx

### モデル検索

- **Ollama Model Library**: https://ollama.ai/library
- **Hugging Face**: https://huggingface.co/models

### コミュニティ

- **Ollama Discord**: コミュニティサポート
- **Reddit r/LocalLLaMA**: ローカルLLM全般

---

## 🎯 次のステップ

1. **まず試す**: Ollamaで小さいモデル(Gemma 2 7B)を試す
2. **用途を絞る**: 会話用かコーディング用か決める
3. **比較する**: 複数モデルを試して好みを見つける
4. **統合する**: 自分のワークフローに組み込む

---

## ⚠️ 注意事項

- モデルのダウンロードには時間がかかる(7Bで4-5GB程度)
- 初回起動は遅いがキャッシュ後は高速化
- メモリ16GBでは13B以上は余裕がない
- バックグラウンドアプリを閉じると快適度向上

---

**更新履歴**:
- 2025-12-29: 初版作成
