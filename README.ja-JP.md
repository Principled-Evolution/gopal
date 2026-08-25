<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/hero_banner_dark.svg">
    <img src="diagrams/hero_banner_light.svg" alt="GOPAL: AI コンプライアンスのための Rego ポリシーライブラリ" width="100%">
  </picture>
</div>

<p align="center">
  <a href="README.md">English</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <strong>日本語</strong> |
  <a href="README.ko-KR.md">한국어</a> |
  <a href="README.hi-IN.md">हिन्दी</a>
</p>

<p align="center">
  <em>読める、動かせる、差分を追える、証明できる AI コンプライアンスルール。</em>
</p>
<p align="center">
  <sub>85 ポリシー・国際フレームワーク 8 件・業種別領域 5 分野</sub>
</p>

<p align="center">
  <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg" alt="OPA CI"></a>
  <a href="https://github.com/Principled-Evolution/gopal/stargazers"><img src="https://img.shields.io/github/stars/Principled-Evolution/gopal?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/Principled-Evolution/gopal/releases"><img src="https://img.shields.io/github/v/release/Principled-Evolution/gopal?style=flat-square&color=brightgreen" alt="最新リリース"></a>
  <a href="https://www.openpolicyagent.org/"><img src="https://img.shields.io/badge/OPA-latest-blue.svg?style=flat-square" alt="OPA"></a>
  <a href="https://github.com/StyraInc/regal"><img src="https://img.shields.io/badge/lint-regal-yellow.svg?style=flat-square" alt="Regal"></a>
  <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square" alt="Apache 2.0"></a>
  <img src="https://img.shields.io/badge/policies-85-orange.svg?style=flat-square" alt="85 Policies">
  <img src="https://img.shields.io/badge/frameworks-8-purple.svg?style=flat-square" alt="8 Frameworks">
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome"></a>
</p>

<br>

**GOPAL: Governance Open Policy Agent Library。** AI 規制向けのオープンなポリシーパックだと考えてください。

Rego で記述された [OPA](https://www.openpolicyagent.org/) ポリシーを厳選したコレクションで、EU AI Act、NIST AI RMF、航空安全標準、教育分野の FERPA / COPPA、銀行業の公正融資規則など、実際の AI ガバナンス要件をコードで表現しています。

AI システムのメタデータ、モデルカード、評価結果に対してこれらのポリシーを実行すると、構造化された機械可読のコンプライアンス判定が得られ、CI、監査ログ、規制当局への提出資料にそのまま組み込めます。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram1_hero_numbers_dark.svg">
    <img src="diagrams/diagram1_hero_numbers_light.svg" alt="GOPAL のカバレッジ: 85 ポリシー、国際規格、航空、業種別、共通原則の各カテゴリ" width="85%" />
  </picture>
</p>

---

## 読める、動かせる、差分を追える、証明できる AI コンプライアンスルール

GOPAL は、EU AI Act、NIST AI RMF、航空安全標準、FERPA / COPPA、公正融資規則、医療安全といった規制・ガバナンス要件を、実行可能な OPA ポリシーに変換します。

次のような AI ガバナンスチェックを求めるなら、GOPAL が向いています。

- **読める**:すべてのルールは Rego であり、ブラックボックスのスコアではありません
- **レビューできる**:ポリシーの変更はプルリクエストを通過します
- **テストできる**:各ポリシーに allow / deny のテストケースを持たせられます
- **バージョン管理できる**:フレームワークが進化しても、バージョンを固定した利用者に影響しません
- **自動化できる**:CI/CD、監査ワークフロー、AICertify の中でチェックを実行できます

---

## なぜ今なのか

EU AI Act はすでに施行されています。NIST AI RMF は事実上の米国標準になっています。英国、インド、ブラジル、シンガポール、カリフォルニア州も動き出しています。航空当局は AI / UAS に関するガイダンスを公表し、金融当局はモデルリスクに関する要件を打ち出しています。

エンジニアリングチームに必要なのは、CI の中で実行できる AI ガバナンスチェックであって、共有ドライブに眠る PDF でも、レビュー資料に貼り付けたスクリーンショットでもありません。

GOPAL は、これらそれぞれの制度に対応する実行可能な Rego ポリシーを提供します。バージョン管理され、テストでき、プルリクエストでレビューできます。プラットフォームチームがすでに Kubernetes の admission control で使っているのと同じツールチェーンを、そのまま AI システムの要件適用に転用できます。

---

## クイックスタート

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram5_evaluation_flow_dark.svg">
    <img src="diagrams/diagram5_evaluation_flow_light.svg" alt="GOPAL の評価フロー:入力 JSON、Rego ポリシー、OPA 評価、判定" width="85%" />
  </picture>
</p>

### 30 秒で GOPAL を試す

```bash
git clone https://github.com/Principled-Evolution/gopal.git
cd gopal/examples/eu-ai-act-transparency
./run.sh
```

サンプル AI システムに対する、構造化された EU AI Act 透明性の判定結果が表示されます。NIST AI RMF やカスタマーサポート LLM など、他の例は [`examples/`](examples/) を参照してください。

### OPA CLI で単体利用する

```bash
# Get OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa

# Clone gopal
git clone https://github.com/Principled-Evolution/gopal.git && cd gopal

# Evaluate your input against the EU AI Act
./opa eval -d international/eu_ai_act/v1 \
  --input my_ai_system.json \
  "data.international.eu_ai_act.v1.transparency.allow"
```

### AICertify のポリシーエンジンとして利用する

```python
from aicertify import regulations, application

regs = regulations.create("eu_compliance")
regs.add("eu_ai_act")  # gopal policies under the hood

app = application.create(name="my-llm-app", ...)
await app.evaluate(regulations=regs, report_format="pdf")
```

Python フレームワーク全体については [AICertify](https://github.com/Principled-Evolution/aicertify) を参照してください。

---

## GOPAL が選ばれる理由

「AI ガバナンス」の多くは、スライド資料の中にしか存在しません。数少ないオープンな実装も、次のいずれかに偏りがちです。

- **汎用の OPA バンドル**(Kubernetes の admission には最適ですが、EU AI Act には不向き)、または
- **クローズドな SaaS**。自分たちが何を基準に評価されているのか見えません。

GOPAL は次の 3 点で異なります。

1. **設計段階から AI 特化。** すべてのポリシーが、バイアス、透明性、人間による監督、モデルリスク、コンテンツ安全性、安全クリティカルな認証など、AI システム固有の懸念を対象とし、汎用インフラは対象にしていません。
2. **読める。** ルールはすべて Rego です。`cat` で開き、PR で差分を確認し、内容を推論できます。ブラックボックスのスコアカードはありません。
3. **バージョン管理されている。** すべてのフレームワークは `v1/`(続いて `v2/` など)の配下に置かれ、明示的なセマンティックバージョニングを保証します。詳細は [COMPATIBILITY.md](COMPATIBILITY.md) を参照してください。EU AI Act が改正されても、旧バージョンはそのまま残ります。

---

## OPA / Rego ユーザー向け

すでに Kubernetes の admission control、クラウドの認可、CI/CD、サービスメッシュで OPA を使っているなら、GOPAL はインフラではなく AI システムを対象にしたポリシーライブラリを提供します。

パッケージ構成、命名規約、テストパターンはすべて素の Rego のイディオムに従っており、独自 DSL もなく、評価に Python も不要です。次のようなことができます。

- 個別のフレームワーク(`international/eu_ai_act/v1/`、`industry_specific/aviation/v1/` など)を自分のバンドルに取り込む
- `opa eval`、[Conftest](https://www.conftest.dev/)、または既存の OPA サーバーで評価する
- メジャーバージョン(`v1/`)に固定し、アップグレードを PR としてレビューする
- 同じ評価の中で GOPAL のルールと自組織の `custom/` ルールを組み合わせる
- [Regal](https://github.com/StyraInc/regal) でリントする。GOPAL 自体も CI で同じリンターを使っています

入力の取り込みと PDF / Markdown レポート生成までまとめて任せられる Python フレームワークが欲しい場合は、[AICertify](https://github.com/Principled-Evolution/aicertify) を参照してください。

---

## 同梱内容

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram2_directory_tree_dark.svg">
    <img src="diagrams/diagram2_directory_tree_light.svg" alt="GOPAL のディレクトリ構成:4 つのトップレベル分岐、管轄区域と業種ごとに整理されたポリシー" width="85%" />
  </picture>
</p>

```
gopal/
├── international/        Frameworks crossing borders
│   ├── eu_ai_act/v1/         29 policies — EU AI Act 2024/1689
│   ├── nist/v1/              5  policies — NIST AI RMF + AI 600-1
│   ├── india/v1/             1  policy   — Digital India Policy
│   ├── brazil/v1/            1  policy   — AI Governance Bill
│   ├── icao/v1/              1  policy   — ICAO Doc 10019
│   ├── faa/v1/               2  policies — Part 107, Remote ID
│   ├── easa/v1/              2  policies — Regulation 2019/947, SORA
│   └── standards/v1/         2  policies — RTCA DO-365, ISO 21384
│
├── industry_specific/    Vertical-specific requirements
│   ├── education/v1/         12 policies — FERPA, COPPA, proctoring, grading
│   ├── aviation/v1/          12 policies — airworthiness, autonomy, data, ops
│   ├── healthcare/v1/         2 policies — patient & diagnostic safety
│   ├── bfs/v1/                2 policies — model risk, fair lending
│   └── automotive/v1/         1 policy   — vehicle safety integration
│
├── global/v1/             9  policies — accountability, fairness, transparency,
│                                       explainability, content safety,
│                                       risk management, security, common rules
│
├── operational/          DevOps & corporate
│   ├── aiops/v1/              1 policy   — scalability
│   ├── cost/v1/               1 policy   — resource efficiency
│   └── corporate/v1/          2 policies — InfoSec, governance
│
├── helper_functions/     Shared utilities for policy authors
│   ├── reporting.rego        Standardized report-output helpers
│   └── validation.rego       Field-presence and required-field checks
│
└── custom/               Your private policies (git-ignored, CI-skipped)
```

**本番運用可能なポリシー 85 個、テストを含む Rego ファイル 124 個。**

---

## 比較

| | GOPAL | 汎用 OPA バンドル | ベンダー製ガバナンス SaaS |
|---|---|---|---|
| AI システムを明確に対象 | ✅ | ❌ | ✅ |
| オープンソース(Apache 2.0) | ✅ | ✅ | ❌ |
| すべてのルールを読める | ✅ Rego | ✅ Rego | ❌ 非公開 |
| 名前の付いた規制への追従(EU AI Act、NIST RMF、FAA) | ✅ 10 以上 | ❌ | 部分対応 |
| 業種別ポリシー標準装備 | ✅ 5 領域 | ❌ | 限定的 |
| 航空 / 安全クリティカル分野のカバレッジ | ✅ ICAO、RTCA、FAA、EASA、ISO | ❌ | ❌ |
| 教育分野(FERPA / COPPA) | ✅ | ❌ | 稀 |
| バージョン管理されたポリシー(`v1/`、`v2/` …) | ✅ Semver | 場合による | 該当なし |
| CI/CD 連携 | ✅ `opa check` + Regal | ✅ | 場合による |
| カスタムのローカルポリシー(上流に共有しない) | ✅ `custom/` は git 管理外 | ❌ | 有償プラン |

他に知っておく価値のあるオープンソースプロジェクトとして、[VerifyWise](https://github.com/verifywise-ai/verifywise) と [Compl-AI](https://github.com/compl-ai/compl-ai) はいずれも EU AI Act など複数のフレームワークに沿って AI システムを評価します。[airblackbox](https://github.com/airblackbox) は LangChain、CrewAI、AutoGen などのエージェントフレームワークを実行時にスキャンし、コンプライアンス上のギャップを検出します。GOPAL の違いは、純粋な Rego / OPA であるためすでに Kubernetes やクラウド認可で使っているポリシーツールチェーンにそのまま組み込める点、そして対象が EU AI Act だけに限られない点です。航空、教育、銀行業のフレームワークも同じツリーの中にあり、同じ方法でバージョン管理とテストがされています。

---

## GOPAL と AICertify

| ニーズ | 使うもの |
|---|---|
| 生の Rego ポリシーが欲しい | GOPAL |
| AI アプリケーションを評価してレポートを生成したい | AICertify |
| 既存の OPA ツールチェーンにポリシーを組み込みたい | GOPAL |
| PDF / Markdown / JSON の監査レポートが欲しい | AICertify |

AICertify は内部で GOPAL を使っています。すでに OPA のワークフローがあり、それを AI 向けルールで拡張したいなら GOPAL を選んでください。AI アプリケーションのやり取りを取り込み、監査対応のエビデンスをエンドツーエンドで生成する Python フレームワークが欲しいなら AICertify を選んでください。

---

## ポリシーの記述

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram3_policy_anatomy_dark.svg">
    <img src="diagrams/diagram3_policy_anatomy_light.svg" alt="GOPAL ポリシーの構造:パッケージパス、import、メタデータ、default deny、allow ルール、レポート" width="85%" />
  </picture>
</p>

すべてのポリシーは同じ構造に従います。

```rego
package international.eu_ai_act.v1.transparency

import data.helper_functions.reporting

# Metadata describes the rule for tooling and auditors.
# METADATA
# title: Transparency for general-purpose AI systems
# description: GPAI providers must publish technical documentation per Article 53.

default allow := false

allow if {
    input.system.technical_documentation_published == true
    input.system.training_data_summary_published == true
}

report := reporting.compose_report(
    "eu_ai_act.transparency",
    allow,
    [{"name": "documentation_present", "value": allow, "control_passed": allow}],
)
```

これに対応する `*_test.rego` がテストを担います。CI では次を強制します。

1. **`opa check`**:全パッケージにわたる構文と参照の整合性
2. **`regal lint`**:Rego のスタイルとベストプラクティス

[helper_functions/](helper_functions/) ライブラリは `compose_report()`、`validate_required_fields()`、`field_exists()` を提供しており、誰が書いたルールであってもレポートが統一された形で出力されます。

手順を追った説明は [`docs/tutorials/add-your-first-policy.md`](docs/tutorials/add-your-first-policy.md)、フレームワークごとのカバレッジ表は [`docs/coverage/`](docs/coverage/) を参照してください。

---

## ポリシーの正確性について

GOPAL は法的助言ではありません。ここにあるポリシーはすべて、公開されている規制・ガバナンス要件をエンジニアが解釈し、実行可能な形にしたものです。正しく書くことに努めていますが、あくまで解釈です。

あるルールが規制を誤って読んでいる、あるいは義務を見落としていると思われる場合は、次の情報を添えて issue を立ててください。

- 該当する規制、条項、条文
- あなたの解釈
- 期待する入出力の挙動
- 公式のガイダンス、規制当局の文書、先例など

ポリシーの正確性に関する意見の相違はセキュリティ脆弱性ではありません。脆弱性については [SECURITY.md](SECURITY.md) を参照してください。むしろ、こうした意見の相違こそ公開の場で扱いたい問題であり、コミュニティ全体でルールをレビューし改善していくためのものです。

---

## カスタムポリシー

`custom/` ディレクトリは、**組織独自のプロプライエタリなポリシー**を配置する場所です。

- `.gitignore` 済みで、このリポジトリにはプッシュされません
- CI からスキップされます
- 公開ツリーと同一の構造(`custom/your_org/v1/...`)を採用しています

社内向けの AI ユースケース固有ルールを、フォークせずに追加できます。公開セットと並行して評価されます。

---

## 開発

```bash
# One-time setup
pip install pre-commit
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa && sudo mv opa /usr/local/bin/
curl -L -o regal https://github.com/StyraInc/regal/releases/latest/download/regal_Linux_x86_64 && chmod +x regal && sudo mv regal /usr/local/bin/
pre-commit install

# Run the same checks CI runs
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

PR のワークフローについては [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

---

## ロードマップ

- **NIST のカバレッジ拡充**:Measure / Manage 系コントロールの肉付け
- **英国 AI 規制原則**:イノベーション促進型フレームワークのルール化
- **カリフォルニア SB-1047 の後継法案**:成立後に対応
- **MAS / HKMA の銀行向け AI ガイダンス**:APAC の金融監督

必要なフレームワークがあれば issue を立ててください。

---

## 関連プロジェクト

- **[AICertify](https://github.com/Principled-Evolution/aicertify)**:GOPAL を利用して AI アプリケーションを評価し、監査対応の PDF / MD / JSON レポートを生成する Python フレームワーク。
- **[Open Policy Agent](https://www.openpolicyagent.org/)**:ポリシーエンジン本体。
- **[Regal](https://github.com/StyraInc/regal)**:CI で使用している Rego リンター。

---

## コミュニティとサポート

Rego や OPA、GitHub の作法を知らなくても回答は得られます。

| やりたいこと | 行き先 |
| --- | --- |
| GOPAL を自社の CI・OPA サーバー・プラットフォームに組み込む方法を聞く | [統合ヘルプフォーム](https://github.com/Principled-Evolution/gopal/issues/new?template=integration_help.yml)、または [Q&A ディスカッション](https://github.com/Principled-Evolution/gopal/discussions/new?category=q-a) |
| GOPAL が未対応の規制・標準をリクエストする | [新規フレームワークのリクエスト](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml) |
| 対応済みフレームワーク内の個別ポリシーをリクエストする | [新規ポリシーのリクエスト](https://github.com/Principled-Evolution/gopal/issues/new?template=new_policy.yml) |
| ポリシーが誤った判定を返すことを報告する | [バグ報告](https://github.com/Principled-Evolution/gopal/issues/new?template=bug_report.yml) |
| GitHub ではなくメールで連絡する | **gopal@principledevolution.ai** |
| セキュリティ脆弱性を報告する | [SECURITY.md](SECURITY.md) を参照してください。公開 issue は立てないでください |

多くの疑問は、投稿前に次の 2 つで解決します。[カバレッジマトリクス](docs/coverage)は条文単位で実装状況を示しています。[FAQ](docs/FAQ.md)では適用範囲、入力形式、AICertify との関係を説明しています。

規模の大小を問わず貢献を歓迎します。[CONTRIBUTING.md](CONTRIBUTING.md) をご覧ください。参加にあたっては[行動規範](CODE_OF_CONDUCT.md)が適用されます。

---

## ライセンス

Apache License 2.0。詳細は [LICENSE](LICENSE) を参照してください。

<p align="center"><sub>Maintained by <a href="https://github.com/Principled-Evolution">Principled Evolution</a> · 読める、動かせる、証明できるコンプライアンス。</sub></p>
