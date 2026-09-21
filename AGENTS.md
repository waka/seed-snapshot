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

テストには実際の MySQL が必要（`127.0.0.1:3306`、既定は `root` / パスワード空）。`docker compose up -d --wait` で CI と同じ MySQL 8.0 を起動できる（`compose.yaml`、データは tmpfs なので `docker compose down` で消える）。`DB_HOST` / `DB_PORT` / `DB_USERNAME` / `DB_PASSWORD` で上書き可能（ポートが埋まっている場合は `DB_PORT=13306 docker compose up -d --wait` と同じ `DB_PORT` でテストを実行）、`ARCONFIG` で `test/config.yml` 自体を差し替え可能。`mysqldump` と `mysql` コマンドが PATH 上に必要。テスト用 DB（`activerecord_unittest`, `activerecord_unittest2`）は `test/cases/db_config.rb` が自動作成し、`test/schema/schema.rb` をロードする。

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
