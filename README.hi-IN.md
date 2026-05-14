<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/hero_banner_dark.svg">
    <img src="diagrams/hero_banner_light.svg" alt="GOPAL — The Rego policy library for AI compliance" width="100%">
  </picture>
</div>

<p align="center">
  <a href="README.md">English</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja-JP.md">日本語</a> |
  <a href="README.ko-KR.md">한국어</a> |
  <strong>हिन्दी</strong>
</p>

<p align="center">
  <em>94 पॉलिसीज़। 15+ रेगुलेटरी फ्रेमवर्क्स। 5 इंडस्ट्री वर्टिकल्स। Policy-as-code जिसे आपका ऑडिटर पढ़ सकता है।</em>
</p>

<p align="center">
  <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg" alt="OPA CI"></a>
  <a href="https://github.com/Principled-Evolution/gopal/stargazers"><img src="https://img.shields.io/github/stars/Principled-Evolution/gopal?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/Principled-Evolution/gopal/releases"><img src="https://img.shields.io/badge/version-1.0.0-brightgreen.svg?style=flat-square" alt="Version 1.0.0"></a>
  <a href="https://www.openpolicyagent.org/"><img src="https://img.shields.io/badge/OPA-latest-blue.svg?style=flat-square" alt="OPA"></a>
  <a href="https://github.com/StyraInc/regal"><img src="https://img.shields.io/badge/lint-regal-yellow.svg?style=flat-square" alt="Regal"></a>
  <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square" alt="Apache 2.0"></a>
  <img src="https://img.shields.io/badge/policies-94-orange.svg?style=flat-square" alt="94 Policies">
  <img src="https://img.shields.io/badge/frameworks-15%2B-purple.svg?style=flat-square" alt="15+ Frameworks">
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome"></a>
</p>

<br>

**Governance Open Policy Agent Library** — Rego में लिखी गई [OPA](https://www.openpolicyagent.org/) पॉलिसीज़ का एक क्यूरेटेड संग्रह, जो वास्तविक AI-गवर्नेंस आवश्यकताओं को एनकोड करता है: EU AI Act, NIST AI RMF, एविएशन सेफ्टी स्टैंडर्ड्स, education में FERPA/COPPA, banking में fair-lending नियम, और बहुत कुछ।

इन्हें अपने AI सिस्टम के metadata, model cards, या मूल्यांकन परिणामों के विरुद्ध चलाइए — और एक संरचित, मशीन-रीडेबल कंप्लायंस वर्डिक्ट प्राप्त कीजिए जिसे आप CI, ऑडिट लॉग, या रेगुलेटर सबमिशन में डाल सकते हैं।

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram1_hero_numbers_dark.svg">
    <img src="diagrams/diagram1_hero_numbers_light.svg" alt="GOPAL कवरेज: 94 पॉलिसीज़, इंटरनेशनल स्टैंडर्ड्स, एविएशन, इंडस्ट्री वर्टिकल्स, और क्रॉस-कटिंग सिद्धांत" width="85%" />
  </picture>
</p>

---

## Quick Start

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram5_evaluation_flow_dark.svg">
    <img src="diagrams/diagram5_evaluation_flow_light.svg" alt="GOPAL मूल्यांकन कैसे काम करता है — इनपुट JSON, Rego पॉलिसी, OPA मूल्यांकन, वर्डिक्ट" width="85%" />
  </picture>
</p>

### OPA CLI के साथ स्टैंडअलोन

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

### AICertify के लिए पॉलिसी इंजन के रूप में

```python
from aicertify import regulations, application

regs = regulations.create("eu_compliance")
regs.add("eu_ai_act")  # gopal policies under the hood

app = application.create(name="my-llm-app", ...)
await app.evaluate(regulations=regs, report_format="pdf")
```

पूर्ण Python फ्रेमवर्क के लिए [AICertify](https://github.com/Principled-Evolution/aicertify) देखें।

---

## GOPAL क्यों

अधिकांश "AI governance" स्लाइड डेक्स में रहती है। कुछ ही ओपन इम्प्लीमेंटेशन्स या तो:

- **जेनेरिक OPA बंडल्स** हैं (Kubernetes admission के लिए बढ़िया, EU AI Act के लिए नहीं), या
- **क्लोज़्ड SaaS** हैं जो उन नियमों को छिपाते हैं जिनके आधार पर आपका मूल्यांकन हो रहा है।

GOPAL तीन आयामों में अलग है:

1. **निर्माण से ही AI-विशिष्ट।** हर पॉलिसी एक AI-सिस्टम चिंता को लक्ष्य करती है — बायस, पारदर्शिता, मानवीय निगरानी, मॉडल रिस्क, कंटेंट सेफ्टी, सेफ्टी-क्रिटिकल सर्टिफ़िकेशन — न कि जेनेरिक इन्फ्रास्ट्रक्चर।
2. **पठनीय।** नियम Rego हैं। आप उन्हें `cat` कर सकते हैं, PR में diff कर सकते हैं, और उनके बारे में तर्क कर सकते हैं। कोई ब्लैक-बॉक्स स्कोरकार्ड नहीं।
3. **वर्ज़न्ड।** हर फ्रेमवर्क स्पष्ट semver गारंटी के साथ `v1/` (फिर `v2/`, आदि) के अंतर्गत रहता है — [COMPATIBILITY.md](COMPATIBILITY.md) देखें। जब EU AI Act में संशोधन होता है, पुराना संस्करण यथावत रहता है।

---

## अंदर क्या है

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram2_directory_tree_dark.svg">
    <img src="diagrams/diagram2_directory_tree_light.svg" alt="GOPAL डायरेक्टरी लेआउट — 4 शीर्ष-स्तरीय शाखाएँ, क्षेत्राधिकार और वर्टिकल के अनुसार व्यवस्थित पॉलिसीज़" width="85%" />
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
│   ├── faa/v1/               2  policies — FAA Part 107, Remote ID
│   ├── easa/v1/              2  policies — Regulation 2019/947, SORA
│   └── standards/v1/         4  policies — RTCA DO-365/366, ASTM F3442, ISO 21384
│
├── industry_specific/    Vertical-specific requirements
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

**94 प्रोडक्शन पॉलिसीज़। टेस्ट्स सहित 125 Rego फ़ाइलें।**

---

## तुलना

| | GOPAL | जेनेरिक OPA बंडल | वेंडर गवर्नेंस SaaS |
|---|---|---|---|
| विशेष रूप से AI सिस्टम्स को लक्ष्य करता है | ✅ | ❌ | ✅ |
| ओपन सोर्स (Apache 2.0) | ✅ | ✅ | ❌ |
| आप हर नियम पढ़ सकते हैं | ✅ Rego | ✅ Rego | ❌ छिपा हुआ |
| नामित विनियमनों को ट्रैक करता है (EU AI Act, NIST RMF, FAA) | ✅ 15+ | ❌ | आंशिक |
| बॉक्स से बाहर इंडस्ट्री-विशिष्ट वर्टिकल्स | ✅ 5 | ❌ | सीमित |
| Aviation / safety-critical कवरेज | ✅ ICAO, RTCA, FAA, EASA, ASTM | ❌ | ❌ |
| Education सेक्टर (FERPA / COPPA) | ✅ | ❌ | दुर्लभ |
| वर्ज़न्ड पॉलिसीज़ (`v1/`, `v2/` …) | ✅ Semver | भिन्न | N/A |
| CI/CD इंटीग्रेशन | ✅ `opa check` + Regal | ✅ | भिन्न |
| कस्टम लोकल पॉलिसीज़ (अपस्ट्रीम शेयर नहीं) | ✅ `custom/` git-ignored है | ❌ | पेड टियर |

---

## पॉलिसीज़ लिखना

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram3_policy_anatomy_dark.svg">
    <img src="diagrams/diagram3_policy_anatomy_light.svg" alt="एक GOPAL पॉलिसी की संरचना — package path, imports, metadata, default deny, allow rule, report" width="85%" />
  </picture>
</p>

हर पॉलिसी एक ही आकार का अनुसरण करती है:

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

फिर एक सहोदर `*_test.rego` नियम को कवर करती है। CI लागू करता है:

1. **`opa check`** — सभी पैकेजों में syntax + reference शुद्धता
2. **`regal lint`** — Rego स्टाइल + सर्वोत्तम प्रथाएँ

[helper_functions/](helper_functions/) लाइब्रेरी आपको `compose_report()`, `validate_required_fields()`, और `field_exists()` देती है ताकि रिपोर्ट्स एक समान आकार में निकलें, चाहे नियम किसी ने भी लिखा हो।

---

## कस्टम पॉलिसीज़

`custom/` डायरेक्टरी **आपके संगठन की प्रोप्राइटरी पॉलिसीज़** के लिए है। यह:

- `.gitignore`d है — कभी इस रेपो में पुश नहीं होती
- CI द्वारा छोड़ी गई
- सार्वजनिक ट्री के समान संरचित (`custom/your_org/v1/...`)

बिना फ़ोर्क किए अपने आंतरिक AI उपयोग-केस नियम डालिए। वे सार्वजनिक सेट के साथ-साथ मूल्यांकित होते हैं।

---

## डेवलपमेंट

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

PR वर्कफ़्लो के लिए [CONTRIBUTING.md](CONTRIBUTING.md) देखें।

---

## रोडमैप

- **अधिक NIST कवरेज** — Measure / Manage controls को विस्तारित करना
- **UK AI रेगुलेशन सिद्धांत** — pro-innovation फ्रेमवर्क नियम
- **California SB-1047 successor** — जब अंतिम रूप दिया जाए
- **MAS / HKMA banking AI गाइडेंस** — APAC वित्तीय पर्यवेक्षण
- **अधिक एविएशन वर्टिकल्स** — UAS-विशिष्ट airworthiness

यदि आपको किसी फ्रेमवर्क की आवश्यकता है तो एक issue खोलें।

---

## संबंधित प्रोजेक्ट्स

- **[AICertify](https://github.com/Principled-Evolution/aicertify)** — Python फ्रेमवर्क जो GOPAL का उपयोग करके AI एप्लिकेशन्स का मूल्यांकन करता है और ऑडिट-तैयार PDF/MD/JSON रिपोर्ट्स तैयार करता है।
- **[Open Policy Agent](https://www.openpolicyagent.org/)** — पॉलिसी इंजन।
- **[Regal](https://github.com/StyraInc/regal)** — वह Rego linter जिसका हम CI में उपयोग करते हैं।

---

## लाइसेंस

Apache License 2.0 — [LICENSE](LICENSE) देखें।

<p align="center"><sub><a href="https://github.com/Principled-Evolution">Principled Evolution</a> द्वारा अनुरक्षित · कंप्लायंस जिसे आप पढ़ सकते हैं, चला सकते हैं, और सिद्ध कर सकते हैं।</sub></p>
