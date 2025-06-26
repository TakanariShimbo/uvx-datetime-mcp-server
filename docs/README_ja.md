[English](README.md) | [日本語](README_ja.md) | **README**

# DateTime MCP サーバー (Python)

現在の日付と時刻を様々な形式で取得するツールを提供する Model Context Protocol (MCP)サーバーです。これは Python SDK を使用した MCP サーバーの実装例で、Python で MCP サーバーを構築する方法を示しています。

## 機能

- 複数の形式での現在日時の取得（ISO、Unix タイムスタンプ、人間が読みやすい形式など）
- 環境変数による出力形式の設定
- タイムゾーンのサポート
- カスタム日付形式のサポート
- シンプルなツール：`get_current_time`

## 使用方法

ニーズに応じて以下の例から選択してください：

**基本的な使用方法（ISO 形式）:**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["takanarishimbo-datetime-mcp-server"]
    }
  }
}
```

**人間が読みやすい形式＋タイムゾーン指定:**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["takanarishimbo-datetime-mcp-server"],
      "env": {
        "DATETIME_FORMAT": "human",
        "TIMEZONE": "Asia/Tokyo"
      }
    }
  }
}
```

**Unix タイムスタンプ形式:**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["takanarishimbo-datetime-mcp-server"],
      "env": {
        "DATETIME_FORMAT": "unix",
        "TIMEZONE": "UTC"
      }
    }
  }
}
```

**カスタム形式:**

```json
{
  "mcpServers": {
    "datetime": {
      "command": "uvx",
      "args": ["takanarishimbo-datetime-mcp-server"],
      "env": {
        "DATETIME_FORMAT": "custom",
        "DATE_FORMAT_STRING": "%Y/%m/%d %H:%M",
        "TIMEZONE": "Asia/Tokyo"
      }
    }
  }
}
```

## 設定

サーバーは環境変数を使用して設定できます：

### `DATETIME_FORMAT`

日時のデフォルト出力形式を制御します（デフォルト："iso"）

サポートされる形式：

- `iso`：ISO 8601 形式（2024-01-01T12:00:00.000000+00:00）
- `unix`：秒単位の Unix タイムスタンプ
- `unix_ms`：ミリ秒単位の Unix タイムスタンプ
- `human`：人間が読みやすい形式（Mon, Jan 1, 2024 12:00:00 PM UTC）
- `date`：日付のみ（2024-01-01）
- `time`：時刻のみ（12:00:00）
- `custom`：DATE_FORMAT_STRING 環境変数を使用したカスタム形式

### `DATE_FORMAT_STRING`

カスタム日付形式文字列（DATETIME_FORMAT="custom"の場合のみ使用）
デフォルト："%Y-%m-%d %H:%M:%S"

Python の strftime 形式コードを使用：

- `%Y`：4 桁の年
- `%y`：2 桁の年
- `%m`：2 桁の月
- `%d`：2 桁の日
- `%H`：2 桁の時（24 時間制）
- `%M`：2 桁の分
- `%S`：2 桁の秒

### `TIMEZONE`

使用するタイムゾーン（デフォルト："UTC"）
例："UTC"、"America/New_York"、"Asia/Tokyo"

## 利用可能なツール

### `get_current_time`

現在の日付と時刻を取得

パラメータ：

- `format`（オプション）：出力形式、DATETIME_FORMAT 環境変数を上書き
- `timezone`（オプション）：使用するタイムゾーン、TIMEZONE 環境変数を上書き

## 開発

1. **このリポジトリをクローン**

   ```bash
   git clone https://github.com/TakanariShimbo/uvx-datetime-mcp-server.git
   cd uvx-datetime-mcp-server
   ```

2. **uv を使用して依存関係をインストール**

   ```bash
   uv sync
   ```

3. **サーバーを実行**

   ```bash
   uv run takanarishimbo-datetime-mcp-server
   ```

4. **MCP Inspector でのテスト（オプション）**

   ```bash
   npx @modelcontextprotocol/inspector uv run takanarishimbo-datetime-mcp-server
   ```

## PyPI への公開

このプロジェクトは PyPI の Trusted Publishers 機能を使用して、GitHub Actions からトークンなしで安全に公開します。

### 1. PyPI Trusted Publisher の設定

1. **PyPI にログイン**（必要に応じてアカウントを作成）

   - https://pypi.org/ にアクセス

2. **公開設定に移動**

   - アカウント設定に移動
   - 「Publishing」をクリックまたは https://pypi.org/manage/account/publishing/ にアクセス

3. **GitHub Publisher を追加**
   - 「Add a new publisher」をクリック
   - 「GitHub」を選択
   - 以下を入力：
     - **Owner**: `TakanariShimbo`（あなたの GitHub ユーザー名/組織）
     - **Repository**: `uvx-datetime-mcp-server`
     - **Workflow name**: `pypi-publish.yml`
     - **Environment**: `pypi`（オプションですが推奨）
   - 「Add」をクリック

### 2. GitHub 環境の設定（推奨）

1. **リポジトリ設定に移動**

   - GitHub リポジトリに移動
   - 「Settings」→「Environments」をクリック

2. **PyPI 環境を作成**
   - 「New environment」をクリック
   - Name: `pypi`
   - 保護ルールの設定（オプション）：
     - 必要なレビュアーを追加
     - 特定のブランチ/タグに制限

### 3. GitHub パーソナルアクセストークンの設定（リリーススクリプト用）

リリーススクリプトは GitHub にプッシュする必要があるため、GitHub トークンが必要です：

1. **GitHub パーソナルアクセストークンの作成**

   - https://github.com/settings/tokens にアクセス
   - 「Generate new token」→「Generate new token (classic)」をクリック
   - 有効期限を設定（推奨：90 日またはカスタム）
   - スコープを選択：
     - ✅ `repo`（プライベートリポジトリのフルコントロール）
   - 「Generate token」をクリック
   - 生成されたトークンをコピー（`ghp_`で始まる）

2. **Git にトークンを設定**

   ```bash
   # オプション1：GitHub CLIを使用（推奨）
   gh auth login

   # オプション2：gitを設定してトークンを使用
   git config --global credential.helper store
   # パスワードを求められたら、代わりにトークンを使用
   ```

### 4. 新しいバージョンのリリース

リリーススクリプトを使用して、自動的にバージョン管理、タグ付け、公開をトリガー：

```bash
# 初回セットアップ
chmod +x scripts/release.sh

# パッチバージョンを増分（0.1.0 → 0.1.1）
./scripts/release.sh patch

# マイナーバージョンを増分（0.1.0 → 0.2.0）
./scripts/release.sh minor

# メジャーバージョンを増分（0.1.0 → 1.0.0）
./scripts/release.sh major

# 特定のバージョンを設定
./scripts/release.sh 1.2.3
```

### 5. 公開の確認

1. **GitHub Actions を確認**

   - リポジトリの「Actions」タブに移動
   - 「Publish to PyPI」ワークフローが正常に完了したことを確認

2. **PyPI パッケージを確認**
   - 訪問：https://pypi.org/project/takanarishimbo-datetime-mcp-server/
   - または実行：`pip show takanarishimbo-datetime-mcp-server`

### リリースプロセスフロー

1. `release.sh`スクリプトがすべてのファイルのバージョンを更新
2. git コミットとタグを作成
3. GitHub にプッシュ
4. 新しいタグで GitHub Actions ワークフローがトリガー
5. ワークフローが OIDC を使用して PyPI に認証（トークン不要！）
6. ワークフローがプロジェクトをビルドして PyPI に公開
7. パッケージが`pip install`や`uvx`でグローバルに利用可能になる

## コード品質

このプロジェクトはリンティングとフォーマットに`ruff`を使用しています：

```bash
# リンターを実行
uv run ruff check

# リンティングの問題を修正
uv run ruff check --fix

# コードをフォーマット
uv run ruff format
```

## プロジェクト構造

```
uvx-datetime-mcp-server/
├── src/
│   ├── __init__.py              # パッケージ初期化
│   ├── __main__.py              # メインエントリーポイント
│   └── server.py                # サーバー実装
├── scripts/
│   └── release.sh               # リリース自動化スクリプト
├── docs/
│   ├── README.md                # 英語版ドキュメント
│   └── README_ja.md             # このファイル
├── dist/                        # ビルド出力ディレクトリ
├── .github/
│   └── workflows/
│       └── pypi-publish.yml     # Trusted Publishers を使用した PyPI 公開ワークフロー
├── pyproject.toml               # プロジェクト設定
├── uv.lock                      # 依存関係のロックファイル
└── .gitignore                   # Git の無視ファイル
```

## ライセンス

MIT
