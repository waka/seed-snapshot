# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Codex, etc.) when working with code in this repository.

## 概要

`seed-snapshot` は ActiveRecord (>= 7.0) 向けの gem で、テスト用のシードデータを `mysqldump` / `mysql` CLI で高速にダンプ・リストアする。**MySQL (Mysql2 アダプタ) 専用**で、`Seed::Configuration` の初期化時に他アダプタだと例外を投げる。

## コマンド

```sh
bin/setup                     # bundle install
bundle exec rake              # 全テスト実行（default タスク = test）
bundle exec ruby -Ilib -Itest test/cases/dump_test.rb              # 単一ファイル
bundle exec ruby -Ilib -Itest test/cases/dump_test.rb -n test_dump # 単一テスト
BUNDLE_GEMFILE=gemfiles/ar_7.1.gemfile bundle exec rake            # 特定の ActiveRecord バージョンで実行
bundle exec rake release      # リリース（バージョンは lib/seed_snapshot/version.rb）
```

## テスト環境

テストには実際の MySQL が必要（既定は `127.0.0.1:3306`、`root` / パスワード空）。

```sh
docker compose up -d --wait   # CI と同じ MySQL 8.0 を起動（compose.yaml）
bundle exec rake
docker compose down           # データは tmpfs なので停止すると消える
```

- **接続先の上書き**: `test/config.yml` は `DB_HOST` / `DB_PORT` / `DB_USERNAME` / `DB_PASSWORD` を参照する。`ARCONFIG` で `test/config.yml` 自体を差し替え可能。3306 が埋まっている場合は `DB_PORT=13306 docker compose up -d --wait` で起動し、テストも同じ `DB_PORT` で実行する。
- **起動待ち**: コンテナは起動のたびに初期化が走り、接続可能になるまで数秒かかる。`test/cases/db_config.rb` の `wait_for_connection` が接続エラーの間だけ最大 30 秒リトライするので、`--wait` なしの `docker compose up -d` 直後に実行しても動く。
- **MySQL クライアント**: gem 本体がホスト上で `mysqldump` / `mysql` を実行する。PATH 上に `mysqldump` が無い場合は `test/support/mysql_client.rb` が `test/bin` を PATH に足し、compose の mysql コンテナ内のクライアントを `docker compose exec` 経由で使う（`test/bin/mysqldump` は `test/bin/mysql` へのシンボリックリンク。`-h` / `-P` はコンテナ内の `127.0.0.1:3306` に上書きする）。CI ではランナー（`ubuntu-latest`）にプリインストールされたクライアントが使われる。
- **DB・テーブルの作成**: 各テストが `require 'cases/helper'` → `test/cases/db_config.rb` の順に読み込み、テスト起動時に以下を行う。
  1. `create_database_if_not_exists` が `activerecord_unittest` / `activerecord_unittest2` を作成（DB 名は `test/support/config.rb` の `expand_config` が接続名 `arunit` / `arunit2` に割り当てる。既存なら何もしない）
  2. `ARTest.connect` で `arunit`（`activerecord_unittest`）に接続
  3. `load_schema` が `test/schema/schema.rb` をロードし、`rents` / `books` / `users` を `force: true` で毎回作り直す

  `activerecord_unittest2` は DB を作るだけで、テーブルは作られず現状のテストでも使われていない。

CI（`.github/workflows/main.yml`）は Ruby 3.1〜3.3 × ActiveRecord 7.0〜8.0 のマトリクスを `gemfiles/ar_*.gemfile` で回す（MySQL 8.0）。サポートする AR バージョンを増減する場合は gemfile と CI マトリクスの両方を更新する。

## アーキテクチャ

- `lib/seed-snapshot.rb` — 公開 API（`SeedSnapshot.dump(classes:, ignore_classes:, force:)`, `.restore`, `.exists?`, `.clean`, `.manifest`）。呼び出しごとに `Seed::Configuration` を新規生成する。
- `Seed::Configuration` — 接続情報・パスを解決する。ダンプファイルは `Dir.pwd/tmp/dump/<schema_version>.sql`。`schema_version` は**マイグレーションバージョン一覧の SHA1** なので、マイグレーションが変わるとスナップショットは自動的に無効化（別ファイル扱い）される。`get_all_versions` は AR バージョンごとに `MigrationContext` の API 差異を吸収している。
- `Seed::Snapshot` — dump/restore/clean の本体。モデルクラスから `table_name` を取り出して `Seed::Mysql` に渡す。`ar_internal_metadata` と `schema_migrations` は常に除外（`--ignore-table` は `db.table` 形式が必要）。
- `Seed::Mysql` — `system` でシェルコマンドを組み立てて実行。`mysqldump -t`（データのみ、スキーマなし）。クライアントバージョンが 8 系なら `--skip-column-statistics` を付ける。
- `Seed::Manifest` — シードファイル群の SHA256 を `tmp/dump/seed_manifest.json` に保存し、`diff?` でシード入力の変更を検知するための補助。

## 注意点

- 実際のバージョン定義は `lib/seed_snapshot/version.rb`（gemspec が参照）。`lib/seed/version.rb` は古い残骸で使われていない。
- README の Usage 例（`SeedSnapshot.restore(tables)` / `dump(tables)`）は現在のキーワード引数 API と一致していない。
- テストは `Dir.pwd` 基準で `tmp/dump` を作るため、リポジトリルートから実行すること。
