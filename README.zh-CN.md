<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/hero_banner_dark.svg">
    <img src="diagrams/hero_banner_light.svg" alt="GOPAL：面向 AI 合规的 Rego 策略库" width="100%">
  </picture>
</div>

<p align="center">
  <a href="README.md">English</a> |
  <strong>简体中文</strong> |
  <a href="README.ja-JP.md">日本語</a> |
  <a href="README.ko-KR.md">한국어</a> |
  <a href="README.hi-IN.md">हिन्दी</a>
</p>

<p align="center">
  <em>可读、可运行、可对比、可验证的 AI 合规规则。</em>
</p>
<p align="center">
  <sub>欧盟《人工智能法案》· 英国 AI 框架 · NIST AI RMF · 航空 · 金融服务 · 教育 · 医疗 · 法律实务</sub>
</p>

<p align="center">
  <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg" alt="OPA 持续集成"></a>
  <a href="https://github.com/Principled-Evolution/gopal/stargazers"><img src="https://img.shields.io/github/stars/Principled-Evolution/gopal?style=flat-square" alt="Star 数"></a>
  <a href="https://github.com/Principled-Evolution/gopal/releases"><img src="https://img.shields.io/github/v/release/Principled-Evolution/gopal?style=flat-square&color=brightgreen" alt="最新发布"></a>
  <a href="https://www.openpolicyagent.org/"><img src="https://img.shields.io/badge/OPA-latest-blue.svg?style=flat-square" alt="OPA"></a>
  <a href="https://github.com/open-policy-agent/regal"><img src="https://img.shields.io/badge/lint-regal-yellow.svg?style=flat-square" alt="Regal"></a>
  <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square" alt="Apache 2.0 许可证"></a>
  <a href="https://github.com/open-policy-agent/awesome-opa"><img src="https://awesome.re/mentioned-badge-flat.svg" alt="Mentioned in Awesome OPA"></a>
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="欢迎提交 PR"></a>
</p>

<br>

**GOPAL:Governance Open Policy Agent Library。** 可以把它理解为一套面向 AI 监管的开放策略包。

这是一套精选的 [OPA](https://www.openpolicyagent.org/) 策略集,用 Rego 编写,将真实的 AI 治理要求编码为可执行规则:EU AI Act、NIST AI RMF、航空安全标准、教育领域的 FERPA/COPPA、银行业的公平借贷规则等。

在您 AI 系统的元数据、模型卡片或评估结果上运行这些策略,即可获得结构化的、机器可读的合规判定,直接接入 CI、审计日志或监管报送流程。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram1_hero_numbers_dark.svg">
    <img src="diagrams/diagram1_hero_numbers_light.svg" alt="GOPAL 覆盖范围:91 条策略,涵盖国际标准、航空、行业垂直领域与跨领域原则" width="85%" />
  </picture>
</p>

---

## 可读、可运行、可对比、可验证的 AI 合规规则

GOPAL 把监管与治理要求,包括 EU AI Act、NIST AI RMF、航空安全标准、教育领域的 FERPA/COPPA、银行业的公平借贷规则以及医疗健康安全,转化为可执行的 OPA 策略。

如果您希望 AI 治理检查具备以下特性,GOPAL 值得一试:

- **可阅读**:每条规则都是 Rego 代码,不是黑盒评分
- **可审查**:策略变更通过 Pull Request 提交
- **可测试**:每条策略都可以配套 allow/deny 测试用例
- **可版本化**:框架持续演进,不会破坏已固定版本的用户
- **可自动化**:在 CI/CD、审计流程或 AICertify 中运行检查

---

## 为什么是现在

EU AI Act 已经生效。NIST AI RMF 事实上已成为美国的基准框架。英国、印度、巴西、新加坡和加利福尼亚州都在推进相关立法。航空监管机构正在发布 AI/UAS 指南,金融监管机构也在提出模型风险方面的要求。

工程团队需要能在 CI 中运行的 AI 治理检查,而不是躺在共享盘里的 PDF,也不是贴在评审会 PPT 里的截图。

GOPAL 为上述每一种监管体系都提供了可执行的 Rego 策略。它们经过版本管理、可测试,并可以在 Pull Request 中接受审查。您的平台团队已经在用于 Kubernetes 准入控制的那一套工具链,现在同样可以用来落实 AI 系统的合规要求。

---

## 快速开始

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram5_evaluation_flow_dark.svg">
    <img src="diagrams/diagram5_evaluation_flow_light.svg" alt="GOPAL 评估流程：输入 JSON、Rego 策略、OPA 评估、判定" width="85%" />
  </picture>
</p>

### 30 秒体验 GOPAL

```bash
git clone https://github.com/Principled-Evolution/gopal.git
cd gopal/examples/eu-ai-act-transparency
./run.sh
```

您将看到针对示例 AI 系统生成的结构化 EU AI Act 透明度判定结果。更多示例(NIST AI RMF、客服 LLM 等)请参见 [`examples/`](examples/)。

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

大多数"AI 治理"还停留在幻灯片阶段。少数开源实现要么是:

- **通用 OPA 规则包**(适合 Kubernetes 准入控制,但不适合 EU AI Act),要么是
- **闭源 SaaS**,把您被评判依据的规则隐藏起来。

GOPAL 在三个维度上与众不同:

1. **专为 AI 打造。** 每条策略都针对 AI 系统的关切点,包括偏见、透明度、人工监督、模型风险、内容安全、安全关键型认证,而非通用基础设施。
2. **可阅读。** 规则就是 Rego 代码。您可以用 `cat` 查看、在 PR 中对比差异,并对其进行推理。没有黑盒评分卡。
3. **版本化。** 每个框架都置于 `v1/` 之下(此后是 `v2/` 等),并提供明确的 semver 保证,参见 [COMPATIBILITY.md](COMPATIBILITY.md)。当 EU AI Act 修订时,旧版本保持不变。

---

## 面向 OPA / Rego 用户

如果您已经在用 OPA 做 Kubernetes 准入控制、云端授权、CI/CD 或服务网格,GOPAL 为您提供的是一套面向 AI 系统而非基础设施的策略库。

这些包、约定和测试模式都是地道的 Rego 写法,没有额外的 DSL,评估时也不需要 Python。您可以:

- 把单个框架(如 `international/eu_ai_act/v1/`、`industry_specific/aviation/v1/`)拉取到自己的 bundle 中
- 使用 `opa eval`、[Conftest](https://www.conftest.dev/) 或您现有的 OPA server 进行评估
- 锁定某个主版本(`v1/`),把升级作为 PR 来审查
- 在同一次评估中,将 GOPAL 规则与您私有的 `custom/` 规则组合使用
- 用 [Regal](https://github.com/open-policy-agent/regal) 做代码检查,这也是 GOPAL 自己在 CI 中使用的检查工具

如果您需要一个能处理输入采集并生成 PDF/Markdown 报告的 Python 框架,请参见 [AICertify](https://github.com/Principled-Evolution/aicertify)。

---

## 内容一览

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram2_directory_tree_dark.svg">
    <img src="diagrams/diagram2_directory_tree_light.svg" alt="GOPAL 目录结构：4 个顶级分支,按司法管辖区与行业组织的策略" width="85%" />
  </picture>
</p>

```
gopal/
├── international/        跨境框架
│   ├── eu_ai_act/v1/         29 policies — EU AI Act 2024/1689
│   ├── nist/v1/              5  policies — NIST AI RMF + AI 600-1
│   ├── india/v1/             1  policy   — Digital India Policy
│   ├── brazil/v1/            1  policy   — AI Governance Bill
│   ├── uk/v1/                6  policies — 亲创新原则、UK GDPR 第 22A-22D 条
│   ├── icao/v1/              1  policy   — ICAO Doc 10019
│   ├── faa/v1/               2  policies — Part 107, Remote ID
│   ├── easa/v1/              2  policies — Regulation 2019/947, SORA
│   └── standards/v1/         2  policies — RTCA DO-365, ISO 21384
│
├── industry_specific/    垂直行业要求
│   ├── education/v1/         12 policies — FERPA, COPPA, proctoring, grading
│   ├── aviation/v1/          12 policies — airworthiness, autonomy, data, ops
│   ├── healthcare/v1/         2 policies — patient & diagnostic safety
│   ├── bfs/v1/                4 policies — 模型风险、公平信贷、PRA SS1/23、FCA 消费者责任
│   ├── legal/v1/              3 policies — 引用核验、保密特权、监督
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

**91 条能给出判定的策略,以及它们所引用的 7 个共享库。包括测试在内共 196 个 Rego 文件。** 这些数字由 [`scripts/generate-coverage.sh`](scripts/generate-coverage.sh) 从目录树生成,并在 CI 中校验,因此不会与代码脱节。运行 `jq .totals docs/coverage/coverage.json` 可查看当前数值。

---

## 对比

| | GOPAL | 通用 OPA 规则包 | 厂商治理 SaaS |
|---|---|---|---|
| 专门面向 AI 系统 | ✅ | ❌ | ✅ |
| 开源(Apache 2.0) | ✅ | ✅ | ❌ |
| 每条规则均可阅读 | ✅ Rego | ✅ Rego | ❌ 隐藏 |
| 跟踪具名法规(EU AI Act、NIST RMF、FAA) | ✅ 10+ | ❌ | 部分 |
| 开箱即用的行业垂直领域 | ✅ 5 个 | ❌ | 有限 |
| 航空 / 安全关键领域覆盖 | ✅ ICAO、RTCA、FAA、EASA、ISO | ❌ | ❌ |
| 教育行业(FERPA / COPPA) | ✅ | ❌ | 罕见 |
| 版本化策略(`v1/`、`v2/` …) | ✅ Semver | 视情况 | 不适用 |
| CI/CD 集成 | ✅ `opa check` + Regal | ✅ | 视情况 |
| 自定义本地策略(不上游共享) | ✅ `custom/` 目录已 git-ignore | ❌ | 付费层级 |

值得了解的其他开源项目:[VerifyWise](https://github.com/verifywise-ai/verifywise) 和 [Compl-AI](https://github.com/compl-ai/compl-ai) 都可以针对 EU AI Act 等框架评估 AI 系统,[airblackbox](https://github.com/airblackbox) 则在运行时扫描 LangChain、CrewAI、AutoGen 等 Agent 框架中的合规风险。GOPAL 的不同之处在于它是纯粹的 Rego/OPA,可以直接接入您已经在用于 Kubernetes 或云端授权的策略工具链,并且覆盖范围不止于 EU AI Act。航空、教育、银行业的框架都在同一套代码树中,采用同样的版本管理和测试方式。

---

## GOPAL 与 AICertify

| 需求 | 使用 |
|---|---|
| 我需要原始的 Rego 策略 | GOPAL |
| 我需要评估 AI 应用并生成报告 | AICertify |
| 我需要把策略接入现有的 OPA 工具链 | GOPAL |
| 我需要 PDF/Markdown/JSON 格式的审计报告 | AICertify |

AICertify 底层使用的正是 GOPAL。如果您已经有一套 OPA 工作流,想扩展 AI 专属规则,选 GOPAL。如果您需要一个 Python 框架来捕获 AI 应用的交互过程,并端到端生成审计就绪的证据,选 AICertify。

---

## 策略编写

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram3_policy_anatomy_dark.svg">
    <img src="diagrams/diagram3_policy_anatomy_light.svg" alt="GOPAL 策略的结构：包路径、imports、元数据、默认拒绝、allow 规则、报告" width="85%" />
  </picture>
</p>

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

1. **`opa check`**:跨所有包的语法与引用正确性
2. **`regal lint`**:Rego 风格与最佳实践

[helper_functions/](helper_functions/) 库提供了 `compose_report()`、`validate_required_fields()` 与 `field_exists()`,无论谁编写规则,输出的报告都将拥有统一形态。

详细步骤请参见 [`docs/tutorials/add-your-first-policy.md`](docs/tutorials/add-your-first-policy.md),各框架的覆盖矩阵请参见 [`docs/coverage/`](docs/coverage/)。

---

## 策略准确性

GOPAL 不是法律建议。这里的每条策略都是工程师对公开监管和治理要求的可执行解读,我们尽力把它写对,但它终究是一种解读。

如果您认为某条规则误读了法规,或者遗漏了某项义务,请提交 issue,并附上:

- 相关的法规、章节或条款
- 您的理解
- 您期望的输入/输出行为
- 任何官方指引、监管文本或先例

策略准确性方面的分歧不属于安全漏洞,安全漏洞请参见 [SECURITY.md](SECURITY.md)。恰恰相反,这类分歧正是我们希望被公开讨论的问题,这样社区才能一起审查和改进这些规则。

---

## 自定义策略

`custom/` 目录用于存放**您组织内部的专有策略**。它具备以下特性:

- 已加入 `.gitignore`,永远不会被推送到本仓库
- CI 会跳过
- 结构与公共目录完全一致(`custom/your_org/v1/...`)

您可以放入内部 AI 用例规则,无需 fork 本仓库。它们将与公共策略集一同评估。

---

## 开发

```bash
# 一次性环境准备
pip install pre-commit
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa && sudo mv opa /usr/local/bin/
curl -L -o regal https://github.com/open-policy-agent/regal/releases/latest/download/regal_Linux_x86_64 && chmod +x regal && sudo mv regal /usr/local/bin/
pre-commit install

# 运行与 CI 相同的检查
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

PR 流程请参见 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## 路线图

- **更全面的 NIST 覆盖**:补全 Measure / Manage 控制项
- **英国 AI 监管原则**:鼓励创新的监管框架原则
- **California SB-1047 的后续法案**:待最终定稿后纳入
- **MAS / HKMA 银行业 AI 指引**:亚太地区金融监管

如果您需要某个框架,欢迎提交 issue。

---

## 相关项目

- **[AICertify](https://github.com/Principled-Evolution/aicertify)**:使用 GOPAL 评估 AI 应用并生成审计就绪的 PDF/MD/JSON 报告的 Python 框架。
- **[Open Policy Agent](https://www.openpolicyagent.org/)**:策略引擎。
- **[Regal](https://github.com/open-policy-agent/regal)**:我们在 CI 中使用的 Rego 代码检查工具。

---

## 社区与支持

不了解 Rego、OPA 或 GitHub 的惯例，同样可以在这里得到回答。

| 如果你想 | 请到这里 |
| --- | --- |
| 询问如何把 GOPAL 接入你的 CI、OPA 服务器或平台 | [集成帮助表单](https://github.com/Principled-Evolution/gopal/issues/new?template=integration_help.yml)，或发一个[问答讨论](https://github.com/Principled-Evolution/gopal/discussions/new?category=q-a) |
| 申请 GOPAL 尚未覆盖的法规或标准 | [新框架申请](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml) |
| 申请已覆盖框架内的某条具体策略 | [新策略申请](https://github.com/Principled-Evolution/gopal/issues/new?template=new_policy.yml) |
| 报告某条策略给出了错误结论 | [缺陷报告](https://github.com/Principled-Evolution/gopal/issues/new?template=bug_report.yml) |
| 不用 GitHub，直接发邮件 | **gopal@principledevolution.ai** |
| 报告安全漏洞 | 请参阅 [SECURITY.md](SECURITY.md)，请勿公开提交 issue |

有两处能提前解答大部分疑问。[覆盖矩阵](docs/coverage)逐条款列出了已经实现的内容；[常见问题](docs/FAQ.md)说明了适用范围、输入格式，以及 GOPAL 与 AICertify 的关系。

欢迎任何规模的贡献，详见 [CONTRIBUTING.md](CONTRIBUTING.md)。参与本项目须遵守我们的[行为准则](CODE_OF_CONDUCT.md)。

### 收录于

- [**awesome-opa**](https://github.com/open-policy-agent/awesome-opa)：Open Policy Agent 官方精选列表，Policy Packages 分类
- [**OPA 生态目录**](https://www.openpolicyagent.org/ecosystem/entry/principled-evolution)
- [**Awesome Europe**](https://github.com/GeiserX/awesome-europe)：Digital Regulation 分类
- [**Awesome AI Governance**](https://github.com/agentrust-io/awesome-ai-governance)：Policy as Code 分类
- [**Awesome Responsible AI**](https://github.com/AthenaCore/AwesomeResponsibleAI)：Policy as Code 分类
- [**Awesome AI Agent Governance**](https://github.com/systempromptio/awesome-ai-agent-governance#policy-engines-and-authorisation)：Policy Engines and Authorisation 分类

---

## 许可证

Apache License 2.0,详见 [LICENSE](LICENSE)。

<p align="center"><sub>由 <a href="https://github.com/Principled-Evolution">Principled Evolution</a> 维护 · 可读、可运行、可证明的合规。</sub></p>
