#!/bin/bash

# Script to help with the release process
# リリースプロセスを支援するスクリプト

# =====================
# 1. Validate Arguments
#
# Check if a version argument was provided
#
# Examples:
#   ./scripts/release.sh patch    → Increment patch version (0.1.3 → 0.1.4)
#   ./scripts/release.sh minor    → Increment minor version (0.1.3 → 0.2.0)
#   ./scripts/release.sh major    → Increment major version (0.1.3 → 1.0.0)
#   ./scripts/release.sh 0.2.5    → Set specific version to 0.2.5
#   ./scripts/release.sh 1.0.0-beta.1 → Set pre-release version
#
# 1. 引数の検証
#
# バージョン引数が提供されているかをチェック
#
# 例:
#   ./scripts/release.sh patch    → パッチバージョンを増分 (0.1.3 → 0.1.4)
#   ./scripts/release.sh minor    → マイナーバージョンを増分 (0.1.3 → 0.2.0)
#   ./scripts/release.sh major    → メジャーバージョンを増分 (0.1.3 → 1.0.0)
#   ./scripts/release.sh 0.2.5    → 特定のバージョンを設定 (0.2.5)
#   ./scripts/release.sh 1.0.0-beta.1 → プレリリースバージョンを設定
# =====================
if [ -z "$1" ]; then
  echo "Error: No version specified"
  echo "Usage: ./scripts/release.sh <version|patch|minor|major>"
  echo "Examples:"
  echo "  ./scripts/release.sh 0.1.4    # Set specific version"
  echo "  ./scripts/release.sh patch    # Increment patch version (0.1.3 -> 0.1.4)"
  echo "  ./scripts/release.sh minor    # Increment minor version (0.1.3 -> 0.2.0)"
  echo "  ./scripts/release.sh major    # Increment major version (0.1.3 -> 1.0.0)"
  exit 1
fi

VERSION_ARG=$1

# =====================
# 2. Parse Version Type
#
# Determine if argument is semantic increment or specific version
#
# Examples:
#   Input: "patch" → INCREMENT_TYPE="patch", outputs "Using semantic increment: patch (current version: 0.1.3)"
#   Input: "0.2.0" → SPECIFIC_VERSION="0.2.0", outputs "Using specific version: 0.2.0"
#   Input: "1.0.0-alpha.1" → SPECIFIC_VERSION="1.0.0-alpha.1"
#   Input: "invalid" → Error: "Version must follow semantic versioning"
#
# 2. バージョンタイプの解析
#
# 引数がセマンティック増分か特定のバージョンかを判定
#
# 例:
#   入力: "patch" → INCREMENT_TYPE="patch", 出力 "Using semantic increment: patch (current version: 0.1.3)"
#   入力: "0.2.0" → SPECIFIC_VERSION="0.2.0", 出力 "Using specific version: 0.2.0"
#   入力: "1.0.0-alpha.1" → SPECIFIC_VERSION="1.0.0-alpha.1"
#   入力: "invalid" → エラー: "Version must follow semantic versioning"
# =====================
if [[ "$VERSION_ARG" =~ ^(patch|minor|major)$ ]]; then
  INCREMENT_TYPE=$VERSION_ARG
  CURRENT_VERSION=$(grep -o 'version = "[^"]*"' pyproject.toml | cut -d'"' -f2)
  echo "Using semantic increment: $INCREMENT_TYPE (current version: $CURRENT_VERSION)"
else
  if ! [[ $VERSION_ARG =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+)?(\+[0-9A-Za-z-]+)?$ ]]; then
    echo "Error: Version must follow semantic versioning (e.g., 1.2.3, 1.2.3-beta, etc.)"
    echo "Or use one of: patch, minor, major"
    exit 1
  fi
  SPECIFIC_VERSION=$VERSION_ARG
  echo "Using specific version: $SPECIFIC_VERSION"
fi

# =====================
# 3. Git Branch Check
#
# Ensure we're releasing from main branch
#
# Examples:
#   On main branch → Continue silently
#   On feature/auth → Warning: "You are not on the main branch. Current branch: feature/auth"
#   On develop → Warning: "You are not on the main branch. Current branch: develop"
#   User types 'n' → Script exits with code 1
#   User types 'y' → Script continues with warning acknowledged
#
# 3. Gitブランチのチェック
#
# mainブランチからリリースしていることを確認
#
# 例:
#   mainブランチ上 → 静かに続行
#   feature/authブランチ上 → 警告: "You are not on the main branch. Current branch: feature/auth"
#   developブランチ上 → 警告: "You are not on the main branch. Current branch: develop"
#   ユーザーが'n'を入力 → スクリプトはコード1で終了
#   ユーザーが'y'を入力 → 警告を確認してスクリプト続行
# =====================
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Warning: You are not on the main branch. Current branch: $CURRENT_BRANCH"
  read -p "Do you want to continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# =====================
# 4. Git Status Check
#
# Ensure working directory is clean before release
#
# Examples:
#   Clean directory → Continue silently
#   Modified files → Error: "Working directory is not clean. Please commit or stash your changes."
#   Untracked files → Error: "Working directory is not clean..."
#   Staged changes → Error: "Working directory is not clean..."
#
# 4. Gitステータスのチェック
#
# リリース前に作業ディレクトリがクリーンであることを確認
#
# 例:
#   クリーンなディレクトリ → 静かに続行
#   変更されたファイル → エラー: "Working directory is not clean. Please commit or stash your changes."
#   追跡されていないファイル → エラー: "Working directory is not clean..."
#   ステージされた変更 → エラー: "Working directory is not clean..."
# =====================
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Working directory is not clean. Please commit or stash your changes."
  exit 1
fi

# =====================
# 5. Sync with Remote
#
# Pull latest changes from remote repository
#
# Examples:
#   Up to date → "Already up to date."
#   New commits → "Updating 1a2b3c4..5d6e7f8"
#   Merge conflicts → Script will fail and exit
#   No remote → Error: "fatal: 'origin' does not appear to be a git repository"
#
# 5. リモートとの同期
#
# リモートリポジトリから最新の変更をプル
#
# 例:
#   最新 → "Already up to date."
#   新しいコミット → "Updating 1a2b3c4..5d6e7f8"
#   マージコンフリクト → スクリプトは失敗して終了
#   リモートなし → エラー: "fatal: 'origin' does not appear to be a git repository"
# =====================
echo "Pulling latest changes from origin..."
git pull origin main

# =====================
# 6. Version Consistency Check
#
# Check versions across pyproject.toml, uv.lock, and server.py
#
# Examples:
#   All synced → pyproject.toml: 0.1.3, uv.lock: 0.1.3, server.py: 0.1.3
#   Mismatch → pyproject.toml: 0.1.4, uv.lock: 0.1.3, server.py: 0.1.3
#   Missing version in server.py → server.py: (empty)
#   Different formats → pyproject.toml: 1.0.0, uv.lock: 1.0.0, server.py: 1.0.0
#
# 6. バージョン整合性チェック
#
# pyproject.toml、uv.lock、server.py間でバージョンをチェック
#
# 例:
#   すべて同期 → pyproject.toml: 0.1.3, uv.lock: 0.1.3, server.py: 0.1.3
#   不整合 → pyproject.toml: 0.1.4, uv.lock: 0.1.3, server.py: 0.1.3
#   server.pyにバージョンがない → server.py: (空)
#   異なる形式 → pyproject.toml: 1.0.0, uv.lock: 1.0.0, server.py: 1.0.0
# =====================
PACKAGE_VERSION=$(grep -o 'version = "[^"]*"' pyproject.toml | cut -d'"' -f2)
LOCK_VERSION=$(grep -A 1 'name = "uvx-datetime-mcp-server"' uv.lock | grep 'version = ' | cut -d'"' -f2)
SERVER_VERSION=$(grep -o '__version__ = "[^"]*"' server.py | cut -d'"' -f2)

echo "Current versions:"
echo "- pyproject.toml: $PACKAGE_VERSION"
echo "- uv.lock: $LOCK_VERSION"
echo "- server.py: $SERVER_VERSION"

# =====================
# 7. Version Update Function
#
# Function to update version in server.py file
#
# Examples:
#   update_server_version "0.1.3" "0.1.4" → Changes '__version__ = "0.1.3"' to '__version__ = "0.1.4"'
#   update_server_version "1.0.0" "1.1.0" → Changes '__version__ = "1.0.0"' to '__version__ = "1.1.0"'
#   update_server_version "0.1.0" "1.0.0" → Changes to specific version
#   With commit message → Also creates git commit with provided message
#
# 7. バージョン更新関数
#
# server.pyファイルのバージョンを更新する関数
#
# 例:
#   update_server_version "0.1.3" "0.1.4" → '__version__ = "0.1.3"'を'__version__ = "0.1.4"'に変更
#   update_server_version "1.0.0" "1.1.0" → '__version__ = "1.0.0"'を'__version__ = "1.1.0"'に変更
#   update_server_version "0.1.0" "1.0.0" → 特定のバージョンに変更
#   コミットメッセージ付き → 提供されたメッセージでgitコミットも作成
# =====================
update_server_version() {
  local old_version=$1
  local new_version=$2
  local commit_msg=$3
  
  echo "Updating version in server.py from $old_version to $new_version..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/__version__ = \"$old_version\"/__version__ = \"$new_version\"/" server.py
  else
    # Linux
    sed -i "s/__version__ = \"$old_version\"/__version__ = \"$new_version\"/" server.py
  fi
  git add server.py
  
  if [ -n "$commit_msg" ]; then
    git commit -m "$commit_msg"
  fi
}

# =====================
# 8. Version Mismatch Warning
#
# Warn if versions differ between files and confirm continuation
#
# Examples:
#   No mismatch → Skip this section entirely
#   pyproject.toml: 0.1.4, uv.lock: 0.1.3, server.py: 0.1.3 → "Warning: Version mismatch detected between files."
#   With specific version → "Will update all files to version: 0.2.0"
#   With increment → "Will update all files using increment: patch"
#   User types 'n' → Script exits
#   User types 'y' → Script continues with synchronization
#
# 8. バージョン不整合警告
#
# ファイル間でバージョンが異なる場合に警告し、続行を確認
#
# 例:
#   不整合なし → このセクションを完全にスキップ
#   pyproject.toml: 0.1.4, uv.lock: 0.1.3, server.py: 0.1.3 → "警告: ファイル間でバージョンの不整合が検出されました。"
#   特定のバージョンで → "すべてのファイルをバージョン0.2.0に更新します"
#   増分で → "増分patchを使用してすべてのファイルを更新します"
#   ユーザーが'n'を入力 → スクリプト終了
#   ユーザーが'y'を入力 → 同期してスクリプト続行
# =====================
if [ "$PACKAGE_VERSION" != "$LOCK_VERSION" ] || [ "$PACKAGE_VERSION" != "$SERVER_VERSION" ]; then
  echo "Warning: Version mismatch detected between files."
  
  if [ -n "$SPECIFIC_VERSION" ]; then
    echo "Will update all files to version: $SPECIFIC_VERSION"
  else
    echo "Will update all files using increment: $INCREMENT_TYPE"
  fi
  
  read -p "Do you want to continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# =====================
# 9. Version Update Process
#
# Update versions in all files and commit changes
#
# Examples:
#   patch increment → 0.1.3 → 0.1.4 (pyproject.toml, server.py)
#   minor increment → 0.1.3 → 0.2.0 (pyproject.toml, server.py)
#   major increment → 0.1.3 → 1.0.0 (pyproject.toml, server.py)
#   specific version → any version → 0.5.0 (pyproject.toml, server.py)
#   Creates commit → "chore: release version 0.1.4"
#   Creates tag → "v0.1.4" with message "Version 0.1.4"
#
# 9. バージョン更新プロセス
#
# すべてのファイルでバージョンを更新し、変更をコミット
#
# 例:
#   パッチ増分 → 0.1.3 → 0.1.4 (pyproject.toml, server.py)
#   マイナー増分 → 0.1.3 → 0.2.0 (pyproject.toml, server.py)
#   メジャー増分 → 0.1.3 → 1.0.0 (pyproject.toml, server.py)
#   特定のバージョン → 任意のバージョン → 0.5.0 (pyproject.toml, server.py)
#   コミット作成 → "chore: release version 0.1.4"
#   タグ作成 → "v0.1.4" メッセージ "Version 0.1.4"
# =====================
if [ -n "$INCREMENT_TYPE" ]; then
  echo "Incrementing version ($INCREMENT_TYPE)..."
  
  CURRENT_VERSION=$(grep -o 'version = "[^"]*"' pyproject.toml | cut -d'"' -f2)
  IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"
  
  if [ "$INCREMENT_TYPE" = "major" ]; then
    major=$((major + 1)); minor=0; patch=0
  elif [ "$INCREMENT_TYPE" = "minor" ]; then
    minor=$((minor + 1)); patch=0
  elif [ "$INCREMENT_TYPE" = "patch" ]; then
    patch=$((patch + 1))
  fi
  
  NEW_VERSION="$major.$minor.$patch"
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml
  else
    sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml
  fi
  
  update_server_version "$SERVER_VERSION" "$NEW_VERSION"
  
  uv lock
  git add pyproject.toml uv.lock
  git commit -m "chore: release version $NEW_VERSION"
  git tag -a "v$NEW_VERSION" -m "Version $NEW_VERSION"
else
  echo "Updating version in pyproject.toml and uv.lock..."
  
  CURRENT_VERSION=$(grep -o 'version = "[^"]*"' pyproject.toml | cut -d'"' -f2)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/version = \"$CURRENT_VERSION\"/version = \"$SPECIFIC_VERSION\"/" pyproject.toml
  else
    sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$SPECIFIC_VERSION\"/" pyproject.toml
  fi
  
  update_server_version "$SERVER_VERSION" "$SPECIFIC_VERSION"
  
  uv lock
  git add pyproject.toml uv.lock
  git commit -m "chore: release version $SPECIFIC_VERSION"
  git tag -a "v$SPECIFIC_VERSION" -m "Version $SPECIFIC_VERSION"
fi

# =====================
# 10. Push to Remote
#
# Push commit and tag to GitHub repository
#
# Examples:
#   Successful push → "Enumerating objects: 5, done."
#   New tag creation → "To github.com:TakanariShimbo/npx-datetime-mcp-server.git * [new tag] v0.1.4 -> v0.1.4"
#   Authentication required → Prompts for GitHub username/token
#   Network error → "fatal: unable to access 'https://github.com/...': Could not resolve host"
#   Push triggers GitHub Actions → Workflow starts automatically for tag v0.1.4
#
# 10. リモートへのプッシュ
#
# コミットとタグをGitHubリポジトリにプッシュ
#
# 例:
#   成功したプッシュ → "Enumerating objects: 5, done."
#   新しいタグ作成 → "To github.com:TakanariShimbo/npx-datetime-mcp-server.git * [new tag] v0.1.4 -> v0.1.4"
#   認証が必要 → GitHubユーザー名/トークンのプロンプト
#   ネットワークエラー → "fatal: unable to access 'https://github.com/...': Could not resolve host"
#   プッシュでGitHub Actionsがトリガー → タグv0.1.4でワークフローが自動開始
# =====================
FINAL_VERSION=$(grep -o 'version = "[^"]*"' pyproject.toml | cut -d'"' -f2)

echo "Pushing changes and tag to remote..."
git push origin main
git push origin v$FINAL_VERSION

# =====================
# 11. Success Message
#
# Display completion message and next steps
#
# Examples:
#   "Release process completed for version 0.1.4"
#   "The GitHub workflow will now build and publish the package to npm"
#   "Check the Actions tab in your GitHub repository for progress"
#   User should visit: https://github.com/TakanariShimbo/npx-datetime-mcp-server/actions
#   Package will be available at: https://pypi.org/project/uvx-datetime-mcp-server/
#
# 11. 成功メッセージ
#
# 完了メッセージと次のステップを表示
#
# 例:
#   "バージョン0.1.4のリリースプロセスが完了しました"
#   "GitHubワークフローがパッケージをビルドしてnpmに公開します"
#   "進捗状況はGitHubリポジトリのActionsタブで確認してください"
#   ユーザーが訪問すべき場所: https://github.com/TakanariShimbo/datetime-mcp-server/actions
#   パッケージの公開場所: https://pypi.org/project/uvx-datetime-mcp-server/
# =====================
echo "Release process completed for version $FINAL_VERSION"
echo "The GitHub workflow will now build and publish the package to PyPI"
echo "Check the Actions tab in your GitHub repository for progress"