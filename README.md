# FXHACK

Hugo + PaperMod で運用している技術ブログです。

公開 URL:
https://ShoheiOkazaki.github.io/FXHACK/

## Repository Layout

- `content/`: 記事と固定ページのソース
- `layouts/`: 独自 shortcode / layout override
- `static/`: favicon, OGP, profile image などの共通アセット
- `archetypes/`: 新規記事テンプレート
- `scripts/`: ローカル運用用スクリプト
- `docs/`: Hugo が生成する公開物

`docs/` は生成物です。手で編集せず、`content/`, `layouts/`, `static/`, `config.yml` を編集してから再生成してください。

## Build

標準ビルドコマンド:

```bash
./scripts/build.sh
```

Hugo を直接使う場合:

```bash
HUGO_ENVIRONMENT=production HUGO_ENV=production hugo --gc --minify
```

`docs/` に `localhost:1313` を含む出力をコミットしないでください。

## Writing Posts

記事は `content/posts/YYYY-MM-DD/` の page bundle として管理します。

各記事ディレクトリの正規形:

- `index.ja.md`
- `index.en.md`
- 本文で使う画像などの軽量アセット

新規記事の雛形作成:

```bash
./scripts/new-post.sh 2026-04-13
```

上のコマンドは `index.ja.md` と `index.en.md` を同時に作成します。

## Asset Policy

- 画像のように本文と密結合な軽量アセットだけを記事フォルダ内に置く
- `.hip*`, `.mp4`, `.zip`, `.xlsx`, `.bmp` など再配布向けファイルは GitHub Releases か外部ストレージへ移す
- 既存の重い添付ファイルは `BINARY_ASSET_BACKLOG.md` で移行管理する
