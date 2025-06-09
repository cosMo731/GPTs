# AGENTS Guidelines

このリポジトリで作業する際の開発ルールをまとめています。プルリクエストを作成する前に必ず確認してください。

## 1. コーディングスタイル

### フォーマッタ設定
- **Python**: `black==23.7.0` を使用し、`--target-version py312 --line-length 100` で実行します。CI では `black --check` を必須とします。
- **JavaScript/TypeScript**: `prettier@3.0.0` を利用し、`src/**/*.{ts,js,vue}` を対象に `prettier --write` を実行します。

### インデント/改行
- Python: 4 スペースインデント。
- Vue/JS/TS: 2 スペースインデント。
- 1 行あたりの最大文字数は 100 文字とし、超える場合は適切に改行します。

### 命名規則
- ファイル/ディレクトリは `snake_case` を基本とします。
- クラス名は `PascalCase`、変数名・関数名は `snake_case` を使用します。
- `Repository` `Service` などのサフィックスは用途を明確にするために付けてください。

### 静的解析
- `ruff==0.1.6` でコードスタイルを検査します。エラーは CI で失敗させます。
- `mypy --strict` による型チェックを必須とします。

### モノレポ差分
- `packages/frontend` 配下のみ `.prettierrc` の設定を独自に許可します。

## 2. テストと品質保証

### テスト階層
- 単体テスト: `pytest` を使用します。
- 結合テスト: `docker-compose` で依存サービスを起動して実行します。
- E2E テスト: `Playwright` を利用します。

### 実行コマンド
- 単体テスト: `pytest -q tests/`。
- E2E テスト: `npm run test:e2e`。
- docker compose の起動は `docker compose up -d`、終了は `docker compose down` を利用します。

### カバレッジ閾値
- `--cov=src --cov-fail-under=85` を指定し、85% 未満なら CI を失敗させます。

### リトライ & キャッシュ
- `pytest --reruns 2` で 2 回まで自動リトライします。
- pip、npm のキャッシュを利用して CI 時間を短縮します。

### セキュリティスキャン
- `trivy fs --severity CRITICAL,HIGH .` を実行し、脆弱性が検出された場合は失敗させます。
- `gitleaks detect` で機密情報の漏洩をチェックします。

## 3. ビルド・デプロイ手順

### ローカルビルド
- `make build` でビルドします。Docker を利用する場合は `docker compose up --build` を実行します。

### CI/CD ワークフロー
- 本番環境: `deploy-prod`、検証環境: `deploy-staging`、プレビュー環境: `preview-env` のワークフローを用意します。

### 環境変数管理
- `.env*` ファイルは Git にコミットしないでください。必要に応じて `AWS Secrets Manager` や `GitHub Secrets` を利用します。
- 秘密鍵は定期的にローテーションし、不要になったものは即座に削除してください。

### プレースホルダ化の徹底
環境やリソースの値は **決してハードコーディングせず**、下表のように GitLab CI/CD 変数や Docker `ARG` を使って参照してください。

| 用途 | プレースホルダ | 補足 |
| ---- | -------------- | ---- |
| コンテナレジストリ | `${CI_REGISTRY}` / `${CI_REGISTRY_IMAGE}` | GitLab 提供のビルトイン変数 |
| ECR URL | `${AWS_ECR_ACCOUNT_URL}` | リージョンやアカウントに応じて変化 |
| AWS リージョン | `${AWS_REGION}` | 例: `ap-northeast-1` |
| Docker イメージタグ | `${CI_COMMIT_SHA}` / `${CI_COMMIT_REF_SLUG}` | `latest` だけに依存しない |
| CI 用カスタムイメージ | `${MY_CI_IMAGE}` | ビルド後に変数で指定 |
| Django シークレット | `${DJANGO_SECRET_KEY}` | Protected & Masked を有効化 |
| DB 接続情報 | `${DB_HOST}` `${DB_PORT}` `${DB_NAME}` `${DB_USER}` `${DB_PASSWORD}` | 環境ごとに切り替え |
| AWS 認証情報 | `${AWS_ACCESS_KEY_ID}` `${AWS_SECRET_ACCESS_KEY}` | `terraform` や `aws-cli` 用 |
| Terraform バックエンド | `${TF_STATE_BUCKET}` `${TF_STATE_KEY}` | S3 のバケット名とキー |
| Terraform ワークスペース | `${TF_WORKSPACE}` | 例: `${CI_COMMIT_REF_SLUG}` |
| Slack Webhook | `${SLACK_WEBHOOK_URL}` | 通知トークン |

Dockerfile では次のように `ARG` を宣言し、CI から `--build-arg` で値を注入してください。

```Dockerfile
ARG TARGET_ENV=develop
ARG MY_CI_IMAGE
```

.gitlab-ci.yml では以下のように変数を定義し、実際の値を外部から渡します。

```yaml
variables:
  MY_CI_IMAGE: ${MY_CI_IMAGE}
  AWS_REGION: ${AWS_REGION}
  AWS_ECR_ACCOUNT_URL: ${AWS_ECR_ACCOUNT_URL}
  DJANGO_SECRET_KEY: ${DJANGO_SECRET_KEY}
  DB_HOST: ${DB_HOST}
  DB_PORT: ${DB_PORT}
  DB_NAME: ${DB_NAME}
  DB_USER: ${DB_USER}
  DB_PASSWORD: ${DB_PASSWORD}
  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
  AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
  TF_STATE_BUCKET: ${TF_STATE_BUCKET}
  TF_STATE_KEY: ${TF_STATE_KEY}
  TF_WORKSPACE: ${TF_WORKSPACE}
  SLACK_WEBHOOK_URL: ${SLACK_WEBHOOK_URL}
```

上記変数は必ず GitLab の CI/CD 設定画面で登録し、`Protected` および `Masked` を適用してください。

### アーティファクト管理
- コンテナイメージタグは `myapp:{semver}-{gitsha}` の形式とします。
- リリース物は 6 か月間保持し、署名付きで管理します。

### ロールバック戦略
- `argocd app rollback myapp <REVISION>` でロールバックを行います。

## 4. ドキュメント更新ポリシー

### 必須更新ファイル
- 変更に伴い `README.md`、`docs/api/openapi.yaml`、`CHANGELOG.md` を更新してください。

### 自動生成ドキュメント
- `sphinx-build -b html docs docs/_build` を実行し、生成物の差分を PR に含めます。

### ドキュメントカバレッジ
- Python コードの docstring 充足率は 80% 以上を目指します。

### ADR 追加基準
- 複数システムに影響する変更、または戻すコストが 2 人日を超える場合は ADR を追加してください。

### レビュー体制
- `doc` ラベルが付いた PR は Tech Writer チームがレビューします。

## 5. コミット・PR メッセージ規約

### コミット規約
- [Conventional Commits](https://www.conventionalcommits.org/) を採用します。例: `feat(auth): add OIDC login flow`。

### PR テンプレート
- 変更概要、試験結果、影響範囲、セキュリティ観点を PR 説明欄に記載してください。

### 自動レビュアーアサイン
- `CODEOWNERS` に基づき自動でレビュアーがアサインされます。`infrastructure/**` 変更時は `@infra-team` がレビュアーとなります。

### ラベル & ブランチ戦略
- ラベル: `feat`, `hotfix`, `infra` を使用します。
- ブランチは trunk-based を基本とし、`feature/{jira-key}` や `release/v{semver}` と命名してください。

### CI ブロッカー条件
- `commitlint --config commitlint.config.js` でコミットメッセージを検査し、失敗した場合は CI を通過できません。

