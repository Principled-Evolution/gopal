<h1 align="center">GOPAL</h1>

<p align="center">
  <a href="README.md">English</a> |
  <strong>简体中文</strong> |
  <a href="README.ja-JP.md">日本語</a> |
  <a href="README.ko-KR.md">한국어</a> |
  <a href="README.hi-IN.md">हिन्दी</a>
</p>

<p align="center">
  <strong>面向 AI 合规的 Rego 策略库。</strong>
</p>

<p align="center">
  <em>94 条策略。15+ 法规框架。5 个行业垂直领域。审计师能读懂的策略即代码。</em>
</p>

<p align="center">
  <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg" alt="OPA 持续集成"></a>
  <a href="https://github.com/Principled-Evolution/gopal/stargazers"><img src="https://img.shields.io/github/stars/Principled-Evolution/gopal?style=flat-square" alt="Star 数"></a>
  <a href="https://github.com/Principled-Evolution/gopal/releases"><img src="https://img.shields.io/badge/version-1.0.0-brightgreen.svg?style=flat-square" alt="版本 1.0.0"></a>
  <a href="https://www.openpolicyagent.org/"><img src="https://img.shields.io/badge/OPA-latest-blue.svg?style=flat-square" alt="OPA"></a>
  <a href="https://github.com/StyraInc/regal"><img src="https://img.shields.io/badge/lint-regal-yellow.svg?style=flat-square" alt="Regal"></a>
  <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square" alt="Apache 2.0 许可证"></a>
  <img src="https://img.shields.io/badge/policies-94-orange.svg?style=flat-square" alt="94 条策略">
  <img src="https://img.shields.io/badge/frameworks-15%2B-purple.svg?style=flat-square" alt="15+ 框架">
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="欢迎提交 PR"></a>
</p>

<br>

**Governance Open Policy Agent Library** —— 精选的 [OPA](https://www.openpolicyagent.org/) 策略集合,以 Rego 编写,将真实的 AI 治理要求编码为可执行规则:EU AI Act、NIST AI RMF、航空安全标准、教育领域的 FERPA/COPPA、银行业的公平借贷规则等。

在您 AI 系统的元数据、模型卡片或评估结果上运行这些策略,即可获得结构化、机器可读的合规判定,可直接接入 CI、审计日志或监管报送。

<p align="center"><img src="diagrams/diagram1_hero_numbers.png" alt="GOPAL —— 94 条策略,15+ 框架,5 个垂直领域" width="85%" /></p>

---

## 快速开始

<p align="center"><img src="diagrams/diagram5_evaluation_flow.png" alt="GOPAL 评估流程 —— 输入 JSON、OPA 引擎、策略、判定" width="85%" /></p>

### 搭配 OPA CLI 独立使用

```bash
# 获取 OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa

# 克隆 gopal
git clone https://github.com/Principled-Evolution/gopal.git && cd gopal

# 依据 EU AI Act 评估您的输入
./opa eval -d international/eu_ai_act/v1 \
  --input my_ai_system.json \
  "data.international.eu_ai_act.v1.transparency.allow"
```

### 作为 AICertify 的策略引擎

```python
from aicertify import regulations, application

regs = regulations.create("eu_compliance")
regs.add("eu_ai_act")  # 底层使用 gopal 策略

app = application.create(name="my-llm-app", ...)
await app.evaluate(regulations=regs, report_format="pdf")
```

完整的 Python 框架请参见 [AICertify](https://github.com/Principled-Evolution/aicertify)。

---

## 为何选择 GOPAL

大多数"AI 治理"只停留在幻灯片里。少数开源实现要么是:

- **通用 OPA 规则包**(适合 Kubernetes 准入控制,但不适合 EU AI Act),要么是
- **闭源 SaaS**,把您被评判依据的规则藏起来。

GOPAL 在三个维度上与众不同:

1. **天然面向 AI。** 每条策略都针对 AI 系统的关切点 —— 偏见、透明度、人类监督、模型风险、内容安全、安全攸关认证 —— 而非通用基础设施。
2. **可阅读。** 规则就是 Rego。您可以 `cat` 查看、在 PR 中对比差异,并对其进行推理。没有黑盒评分卡。
3. **版本化。** 每个框架都置于 `v1/` 之下(此后是 `v2/` 等),并提供明确的 semver 保证 —— 参见 [COMPATIBILITY.md](COMPATIBILITY.md)。当 EU AI Act 修订时,旧版本保持不变。

---

## 内容一览

<p align="center"><img src="diagrams/diagram2_directory_tree.png" alt="GOPAL 目录结构 —— 5 个顶级分支,按司法管辖区与行业组织的策略" width="85%" /></p>

```
gopal/
├── international/        跨境框架
│   ├── eu_ai_act/v1/         29 policies — EU AI Act 2024/1689
│   ├── nist/v1/              5  policies — NIST AI RMF + AI 600-1
│   ├── india/v1/             1  policy   — Digital India Policy
│   ├── brazil/v1/            1  policy   — AI Governance Bill
│   ├── icao/v1/              1  policy   — ICAO Doc 10019
│   ├── faa/v1/               2  policies — FAA Part 107, Remote ID
│   ├── easa/v1/              2  policies — Regulation 2019/947, SORA
│   └── standards/v1/         4  policies — RTCA DO-365/366, ASTM F3442, ISO 21384
│
├── industry_specific/    垂直行业要求
│   ├── aviation/v1/          17 policies — detect & avoid, certification, design
│   ├── education/v1/         12 policies — FERPA, COPPA, proctoring, grading
│   ├── healthcare/v1/         2 policies — patient & diagnostic safety
│   ├── bfs/v1/                2 policies — model risk, fair lending
│   └── automotive/v1/         1 policy   — vehicle safety integration
│
├── global/v1/             9  policies — accountability, fairness, transparency,
│                                       explainability, content safety,
│                                       risk management, security, common rules
│
├── operational/          DevOps 与企业治理
│   ├── aiops/v1/              1 policy   — scalability
│   ├── cost/v1/               1 policy   — resource efficiency
│   └── corporate/v1/          2 policies — InfoSec, governance
│
├── helper_functions/     策略作者的共享工具
│   ├── reporting.rego        Standardized report-output helpers
│   └── validation.rego       Field-presence and required-field checks
│
└── custom/               您的私有策略(已 git-ignore,CI 跳过)
```

**94 条生产级策略。包括测试在内共 125 个 Rego 文件。**

---

## 对比

<p align="center"><img src="diagrams/diagram4_framework_grid.png" alt="GOPAL 覆盖的框架 —— EU AI Act、NIST、FAA、EASA、RTCA 等" width="85%" /></p>

| | GOPAL | 通用 OPA 规则包 | 厂商治理 SaaS |
|---|---|---|---|
| 专门面向 AI 系统 | ✅ | ❌ | ✅ |
| 开源(Apache 2.0) | ✅ | ✅ | ❌ |
| 每条规则均可阅读 | ✅ Rego | ✅ Rego | ❌ 隐藏 |
| 跟踪具名法规(EU AI Act、NIST RMF、FAA) | ✅ 15+ | ❌ | 部分 |
| 开箱即用的行业垂直领域 | ✅ 5 个 | ❌ | 有限 |
| 航空 / 安全攸关领域覆盖 | ✅ ICAO、RTCA、FAA、EASA、ASTM | ❌ | ❌ |
| 教育行业(FERPA / COPPA) | ✅ | ❌ | 罕见 |
| 版本化策略(`v1/`、`v2/` …) | ✅ Semver | 视情况 | 不适用 |
| CI/CD 集成 | ✅ `opa check` + Regal | ✅ | 视情况 |
| 自定义本地策略(不上游共享) | ✅ `custom/` 目录已 git-ignore | ❌ | 付费层级 |

---

## 策略编写

<p align="center"><img src="diagrams/diagram3_policy_anatomy.png" alt="GOPAL 策略的结构 —— 包路径、imports、元数据、默认拒绝、allow 规则、报告" width="85%" /></p>

每条策略都遵循相同的结构:

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

随后由配套的 `*_test.rego` 覆盖该规则。CI 会强制执行:

1. **`opa check`** —— 跨所有包的语法与引用正确性
2. **`regal lint`** —— Rego 风格与最佳实践

[helper_functions/](helper_functions/) 库提供了 `compose_report()`、`validate_required_fields()` 与 `field_exists()`,无论谁编写规则,输出的报告都将拥有统一形态。

---

## 自定义策略

`custom/` 目录用于存放**您组织内部的专有策略**。它具备以下特性:

- 已加入 `.gitignore` —— 永远不会被推送到本仓库
- CI 会跳过
- 结构与公共目录完全一致(`custom/your_org/v1/...`)

您可以放入内部 AI 用例规则,无需 fork 本仓库。它们将与公共策略集一同评估。

---

## 开发

```bash
# 一次性环境准备
pip install pre-commit
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa && sudo mv opa /usr/local/bin/
curl -L -o regal https://github.com/StyraInc/regal/releases/latest/download/regal_Linux_x86_64 && chmod +x regal && sudo mv regal /usr/local/bin/
pre-commit install

# 运行与 CI 相同的检查
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

PR 流程请参见 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## 路线图

- **更全面的 NIST 覆盖** —— 补全 Measure / Manage 控制项
- **英国 AI 监管原则** —— 亲创新框架规则
- **California SB-1047 的后续法案** —— 在最终定稿后纳入
- **MAS / HKMA 银行业 AI 指引** —— 亚太金融监管
- **更多航空垂直领域** —— UAS 专属适航要求

如果您需要某个框架,欢迎开 issue 提出。

---

## 相关项目

- **[AICertify](https://github.com/Principled-Evolution/aicertify)** —— 使用 GOPAL 评估 AI 应用并生成审计就绪的 PDF/MD/JSON 报告的 Python 框架。
- **[Open Policy Agent](https://www.openpolicyagent.org/)** —— 策略引擎。
- **[Regal](https://github.com/StyraInc/regal)** —— 我们在 CI 中使用的 Rego 代码检查工具。

---

## 许可证

Apache License 2.0 —— 参见 [LICENSE](LICENSE)。

<p align="center"><sub>由 <a href="https://github.com/Principled-Evolution">Principled Evolution</a> 维护 · 可读、可运行、可证明的合规。</sub></p>
