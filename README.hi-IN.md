<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/hero_banner_dark.svg">
    <img src="diagrams/hero_banner_light.svg" alt="GOPAL: AI कंप्लायंस के लिए Rego पॉलिसी लाइब्रेरी" width="100%">
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
  <em>AI कंप्लायंस नियम जिन्हें आप पढ़ सकते हैं, चला सकते हैं, diff कर सकते हैं, और सिद्ध कर सकते हैं।</em>
</p>
<p align="center">
  <sub>EU AI Act · UK AI फ्रेमवर्क · NIST AI RMF · एविएशन · फाइनेंशियल सर्विसेज़ · एजुकेशन · हेल्थकेयर · लीगल प्रैक्टिस</sub>
</p>

<p align="center">
  <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg" alt="OPA CI"></a>
  <a href="https://github.com/Principled-Evolution/gopal/stargazers"><img src="https://img.shields.io/github/stars/Principled-Evolution/gopal?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/Principled-Evolution/gopal/releases"><img src="https://img.shields.io/github/v/release/Principled-Evolution/gopal?style=flat-square&color=brightgreen" alt="नवीनतम रिलीज़"></a>
  <a href="https://www.openpolicyagent.org/"><img src="https://img.shields.io/badge/OPA-latest-blue.svg?style=flat-square" alt="OPA"></a>
  <a href="https://github.com/StyraInc/regal"><img src="https://img.shields.io/badge/lint-regal-yellow.svg?style=flat-square" alt="Regal"></a>
  <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square" alt="Apache 2.0"></a>
  <a href="https://github.com/open-policy-agent/awesome-opa"><img src="https://awesome.re/mentioned-badge-flat.svg" alt="Mentioned in Awesome OPA"></a>
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome"></a>
</p>

<br>

**GOPAL: Governance Open Policy Agent Library.** इसे AI रेगुलेशन के लिए एक ओपन पॉलिसी पैक समझिए।

Rego में लिखी गई [OPA](https://www.openpolicyagent.org/) पॉलिसीज़ का एक क्यूरेटेड संग्रह, जो वास्तविक AI-गवर्नेंस आवश्यकताओं को एनकोड करता है: EU AI Act, NIST AI RMF, एविएशन सेफ्टी स्टैंडर्ड्स, education में FERPA/COPPA, banking में fair-lending नियम, और बहुत कुछ।

इन्हें अपने AI सिस्टम के metadata, model cards, या मूल्यांकन परिणामों के विरुद्ध चलाइए, और एक संरचित, मशीन-रीडेबल कंप्लायंस वर्डिक्ट पाइए जिसे आप CI, ऑडिट लॉग, या रेगुलेटर सबमिशन में सीधे इस्तेमाल कर सकते हैं।

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram1_hero_numbers_dark.svg">
    <img src="diagrams/diagram1_hero_numbers_light.svg" alt="GOPAL कवरेज: 85 पॉलिसीज़, इंटरनेशनल स्टैंडर्ड्स, एविएशन, इंडस्ट्री वर्टिकल्स, और क्रॉस-कटिंग सिद्धांत" width="85%" />
  </picture>
</p>

---

## AI कंप्लायंस नियम जिन्हें आप पढ़ सकते हैं, चला सकते हैं, diff कर सकते हैं, और सिद्ध कर सकते हैं

GOPAL रेगुलेटरी और गवर्नेंस आवश्यकताओं को, जैसे EU AI Act, NIST AI RMF, एविएशन सेफ्टी स्टैंडर्ड्स, FERPA/COPPA, fair lending, और healthcare safety को, एक्ज़ीक्यूटेबल OPA पॉलिसीज़ में बदल देता है।

अगर आपको ऐसे AI गवर्नेंस चेक्स चाहिए जो हों:

- **पठनीय**: हर नियम Rego कोड है, कोई ब्लैक-बॉक्स स्कोर नहीं
- **समीक्षा योग्य**: पॉलिसी में बदलाव pull requests से होकर गुज़रते हैं
- **टेस्ट योग्य**: हर पॉलिसी के लिए allow/deny टेस्ट केस बनाए जा सकते हैं
- **वर्ज़न्ड**: फ्रेमवर्क्स आगे बढ़ते रहते हैं, बिना उन यूज़र्स को तोड़े जिन्होंने कोई वर्ज़न पिन कर रखा है
- **ऑटोमेटेबल**: CI/CD, ऑडिट वर्कफ़्लो, या AICertify में चेक्स चलाइए

तो GOPAL आज़माइए।

---

## अभी क्यों

EU AI Act लागू हो चुका है। NIST AI RMF अमेरिका का वास्तविक बेसलाइन बन चुका है। UK, भारत, ब्राज़ील, सिंगापुर, और कैलिफ़ोर्निया, सभी आगे बढ़ रहे हैं। एविएशन रेगुलेटर्स AI/UAS गाइडेंस जारी कर रहे हैं। वित्तीय पर्यवेक्षक मॉडल-रिस्क आवश्यकताएँ जारी कर रहे हैं।

इंजीनियरिंग टीमों को ऐसे AI गवर्नेंस चेक्स चाहिए जो CI में चलें, न कि ऐसे PDF जो किसी शेयर्ड ड्राइव पर पड़े रहें, न ही रिव्यू-बोर्ड डेक में चिपकाए गए स्क्रीनशॉट।

GOPAL इन सभी रेगुलेटरी रिजीम्स के लिए एक्ज़ीक्यूटेबल Rego पॉलिसीज़ देता है। ये वर्ज़न्ड, टेस्टेबल, और pull requests में रिव्यू होने लायक हैं। जो टूलिंग आपकी प्लेटफ़ॉर्म टीम पहले से Kubernetes admission control के लिए इस्तेमाल कर रही है, वही अब AI-सिस्टम आवश्यकताओं को लागू करने के लिए भी काम आ सकती है।

---

## Quick Start

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram5_evaluation_flow_dark.svg">
    <img src="diagrams/diagram5_evaluation_flow_light.svg" alt="GOPAL मूल्यांकन कैसे काम करता है: इनपुट JSON, Rego पॉलिसी, OPA मूल्यांकन, वर्डिक्ट" width="85%" />
  </picture>
</p>

### 30 सेकंड में GOPAL आज़माइए

```bash
git clone https://github.com/Principled-Evolution/gopal.git
cd gopal/examples/eu-ai-act-transparency
./run.sh
```

आपको एक सैंपल AI सिस्टम के विरुद्ध एक संरचित EU AI Act ट्रांसपेरेंसी वर्डिक्ट दिखेगा। NIST AI RMF, customer-support LLM, और अन्य उदाहरणों के लिए [`examples/`](examples/) देखें।

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

अधिकांश "AI governance" स्लाइड डेक्स में ही रह जाती है। कुछ ही ओपन इम्प्लीमेंटेशन्स मौजूद हैं, और वे भी या तो:

- **जेनेरिक OPA बंडल्स** हैं (Kubernetes admission के लिए बढ़िया, EU AI Act के लिए नहीं), या
- **क्लोज़्ड SaaS** हैं जो उन नियमों को छिपाते हैं जिनके आधार पर आपका मूल्यांकन हो रहा है।

GOPAL तीन आयामों में अलग है:

1. **शुरुआत से ही AI-विशिष्ट।** हर पॉलिसी किसी AI-सिस्टम चिंता को लक्ष्य करती है, जैसे बायस, पारदर्शिता, मानवीय निगरानी, मॉडल रिस्क, कंटेंट सेफ्टी, सेफ्टी-क्रिटिकल सर्टिफ़िकेशन, न कि जेनेरिक इन्फ्रास्ट्रक्चर को।
2. **पठनीय।** नियम बस Rego हैं। आप उन्हें `cat` कर सकते हैं, PR में diff कर सकते हैं, और उनके बारे में तर्क कर सकते हैं। कोई ब्लैक-बॉक्स स्कोरकार्ड नहीं।
3. **वर्ज़न्ड।** हर फ्रेमवर्क स्पष्ट semver गारंटी के साथ `v1/` (फिर `v2/`, आदि) के अंतर्गत रहता है, देखें [COMPATIBILITY.md](COMPATIBILITY.md)। जब EU AI Act में संशोधन होता है, पुराना संस्करण यथावत रहता है।

---

## OPA / Rego यूज़र्स के लिए

अगर आप पहले से Kubernetes admission, cloud authorization, CI/CD, या service mesh के लिए OPA इस्तेमाल कर रहे हैं, तो GOPAL आपको इन्फ्रास्ट्रक्चर की बजाय AI सिस्टम्स को लक्ष्य करने वाली एक पॉलिसी लाइब्रेरी देता है।

पैकेज, कन्वेंशन्स, और टेस्ट पैटर्न्स सब इडियोमैटिक Rego हैं, कोई ऊपर से DSL नहीं, evaluate करने के लिए कोई Python भी नहीं चाहिए। आप ये सब कर सकते हैं:

- अलग-अलग फ्रेमवर्क्स (`international/eu_ai_act/v1/`, `industry_specific/aviation/v1/`) को अपने bundle में शामिल कीजिए
- `opa eval`, [Conftest](https://www.conftest.dev/), या अपने मौजूदा OPA server से evaluate कीजिए
- किसी major version (`v1/`) पर पिन कीजिए और अपग्रेड्स को PR के रूप में रिव्यू कीजिए
- GOPAL के नियमों को अपने private `custom/` नियमों के साथ एक ही evaluation में मिलाइए
- [Regal](https://github.com/StyraInc/regal) से lint कीजिए, यही linter GOPAL खुद अपने CI में इस्तेमाल करता है

अगर आपको एक ऐसा Python फ्रेमवर्क चाहिए जो input capture और PDF/Markdown रिपोर्ट जनरेशन भी संभाल ले, तो [AICertify](https://github.com/Principled-Evolution/aicertify) देखें।

---

## अंदर क्या है

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram2_directory_tree_dark.svg">
    <img src="diagrams/diagram2_directory_tree_light.svg" alt="GOPAL डायरेक्टरी लेआउट: 4 शीर्ष-स्तरीय शाखाएँ, क्षेत्राधिकार और वर्टिकल के अनुसार व्यवस्थित पॉलिसीज़" width="85%" />
  </picture>
</p>

```
gopal/
├── international/        Frameworks crossing borders
│   ├── eu_ai_act/v1/         29 policies — EU AI Act 2024/1689
│   ├── nist/v1/              5  policies — NIST AI RMF + AI 600-1
│   ├── india/v1/             1  policy   — Digital India Policy
│   ├── brazil/v1/            1  policy   — AI Governance Bill
│   ├── uk/v1/                6  policies — प्रो-इनोवेशन सिद्धांत, UK GDPR अनुच्छेद 22A-22D
│   ├── icao/v1/              1  policy   — ICAO Doc 10019
│   ├── faa/v1/               2  policies — Part 107, Remote ID
│   ├── easa/v1/              2  policies — Regulation 2019/947, SORA
│   └── standards/v1/         2  policies — RTCA DO-365, ISO 21384
│
├── industry_specific/    Vertical-specific requirements
│   ├── education/v1/         12 policies — FERPA, COPPA, proctoring, grading
│   ├── aviation/v1/          12 policies — airworthiness, autonomy, data, ops
│   ├── healthcare/v1/         2 policies — patient & diagnostic safety
│   ├── bfs/v1/                4 policies — मॉडल जोखिम, फेयर लेंडिंग, PRA SS1/23, FCA उपभोक्ता कर्तव्य
│   ├── legal/v1/              3 policies — उद्धरण सत्यापन, विशेषाधिकार, पर्यवेक्षण
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

**96 प्रोडक्शन पॉलिसीज़। टेस्ट्स सहित कुल 146 Rego फ़ाइलें।**

---

## तुलना

| | GOPAL | जेनेरिक OPA बंडल | वेंडर गवर्नेंस SaaS |
|---|---|---|---|
| विशेष रूप से AI सिस्टम्स को लक्ष्य करता है | ✅ | ❌ | ✅ |
| ओपन सोर्स (Apache 2.0) | ✅ | ✅ | ❌ |
| आप हर नियम पढ़ सकते हैं | ✅ Rego | ✅ Rego | ❌ छिपा हुआ |
| नामित विनियमनों को ट्रैक करता है (EU AI Act, NIST RMF, FAA) | ✅ 10+ | ❌ | आंशिक |
| बॉक्स से बाहर इंडस्ट्री-विशिष्ट वर्टिकल्स | ✅ 5 | ❌ | सीमित |
| Aviation / safety-critical कवरेज | ✅ ICAO, RTCA, FAA, EASA, ISO | ❌ | ❌ |
| Education सेक्टर (FERPA / COPPA) | ✅ | ❌ | दुर्लभ |
| वर्ज़न्ड पॉलिसीज़ (`v1/`, `v2/` …) | ✅ Semver | भिन्न | N/A |
| CI/CD इंटीग्रेशन | ✅ `opa check` + Regal | ✅ | भिन्न |
| कस्टम लोकल पॉलिसीज़ (अपस्ट्रीम शेयर नहीं) | ✅ `custom/` git-ignored है | ❌ | पेड टियर |

जानने लायक कुछ और ओपन-सोर्स प्रोजेक्ट्स: [VerifyWise](https://github.com/verifywise-ai/verifywise) और [Compl-AI](https://github.com/compl-ai/compl-ai), दोनों EU AI Act और अन्य फ्रेमवर्क्स के आधार पर AI सिस्टम्स का मूल्यांकन करते हैं। [airblackbox](https://github.com/airblackbox) LangChain, CrewAI, AutoGen जैसे agent फ्रेमवर्क्स को रनटाइम पर स्कैन करके कंप्लायंस गैप्स ढूँढता है। GOPAL का फ़र्क़ यह है कि यह शुद्ध Rego/OPA है, इसलिए यह उस पॉलिसी टूलिंग में सीधे फ़िट बैठता है जो आप शायद पहले से Kubernetes या cloud authorization के लिए इस्तेमाल कर रहे हों, और यह सिर्फ़ EU AI Act तक सीमित नहीं है। Aviation, education, और banking फ्रेमवर्क्स भी उसी कोड ट्री में हैं, उसी तरह वर्ज़न्ड और टेस्टेड।

---

## GOPAL बनाम AICertify

| ज़रूरत | इस्तेमाल करें |
|---|---|
| मुझे raw Rego पॉलिसीज़ चाहिए | GOPAL |
| मुझे किसी AI ऐप का मूल्यांकन करके रिपोर्ट जनरेट करनी है | AICertify |
| मुझे मौजूदा OPA टूलिंग में पॉलिसीज़ जोड़नी हैं | GOPAL |
| मुझे PDF/Markdown/JSON ऑडिट रिपोर्ट्स चाहिए | AICertify |

AICertify अंदर से GOPAL का ही इस्तेमाल करता है। अगर आपके पास पहले से एक OPA वर्कफ़्लो है और आप उसे AI-विशिष्ट नियमों से बढ़ाना चाहते हैं, तो GOPAL चुनें। अगर आपको एक Python फ्रेमवर्क चाहिए जो AI-एप्लिकेशन इंटरैक्शन्स को कैप्चर करे और शुरू से आख़िर तक ऑडिट-रेडी एविडेंस तैयार करे, तो AICertify चुनें।

---

## पॉलिसीज़ लिखना

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram3_policy_anatomy_dark.svg">
    <img src="diagrams/diagram3_policy_anatomy_light.svg" alt="एक GOPAL पॉलिसी की संरचना: package path, imports, metadata, default deny, allow rule, report" width="85%" />
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

फिर एक सहोदर `*_test.rego` उस नियम को कवर करता है। CI इन्हें लागू करता है:

1. **`opa check`**: सभी पैकेजों में syntax और reference शुद्धता
2. **`regal lint`**: Rego स्टाइल और सर्वोत्तम प्रथाएँ

[helper_functions/](helper_functions/) लाइब्रेरी आपको `compose_report()`, `validate_required_fields()`, और `field_exists()` देती है, ताकि रिपोर्ट्स एक समान आकार में निकलें, चाहे नियम किसी ने भी लिखा हो।

चरण-दर-चरण मार्गदर्शन के लिए [`docs/tutorials/add-your-first-policy.md`](docs/tutorials/add-your-first-policy.md) देखें, और प्रति-फ्रेमवर्क कवरेज मैट्रिक्स के लिए [`docs/coverage/`](docs/coverage/) देखें।

---

## पॉलिसी की सटीकता

GOPAL कानूनी सलाह नहीं है। यहाँ की पॉलिसीज़ सार्वजनिक रेगुलेटरी और गवर्नेंस आवश्यकताओं की एक्ज़ीक्यूटेबल इंटरप्रिटेशन्स हैं, जिन्हें उन इंजीनियर्स ने लिखा है जो इसे सही करना चाहते हैं।

अगर आपको लगता है कि कोई नियम किसी रेगुलेशन को ग़लत पढ़ रहा है, या किसी दायित्व को छोड़ रहा है, तो कृपया एक issue खोलें और साथ में बताएँ:

- वह रेगुलेशन, सेक्शन, या आर्टिकल जिसकी बात हो रही है
- आपकी इंटरप्रिटेशन
- वह input/output व्यवहार जिसकी आप उम्मीद करते हैं
- कोई भी आधिकारिक गाइडेंस, रेगुलेटर टेक्स्ट, या पूर्व उदाहरण

पॉलिसी की सटीकता को लेकर असहमति सुरक्षा भेद्यता नहीं है, सुरक्षा भेद्यता के लिए [SECURITY.md](SECURITY.md) देखें। बल्कि यह ठीक वैसी ही चीज़ है जिसे हम सार्वजनिक रखना चाहते हैं, ताकि कम्युनिटी मिलकर नियमों की समीक्षा और सुधार कर सके।

---

## कस्टम पॉलिसीज़

`custom/` डायरेक्टरी **आपके संगठन की प्रोप्राइटरी पॉलिसीज़** के लिए है। यह:

- `.gitignore`d है, कभी इस रेपो में पुश नहीं होती
- CI द्वारा छोड़ दी जाती है
- सार्वजनिक ट्री जैसी ही संरचित है (`custom/your_org/v1/...`)

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

- **अधिक NIST कवरेज**: Measure / Manage controls को विस्तारित करना
- **UK AI रेगुलेशन सिद्धांत**: pro-innovation फ्रेमवर्क नियम
- **California SB-1047 successor**: जब अंतिम रूप दिया जाए
- **MAS / HKMA banking AI गाइडेंस**: APAC वित्तीय पर्यवेक्षण

अगर आपको किसी फ्रेमवर्क की ज़रूरत है तो एक issue खोलें।

---

## संबंधित प्रोजेक्ट्स

- **[AICertify](https://github.com/Principled-Evolution/aicertify)**: Python फ्रेमवर्क जो GOPAL का उपयोग करके AI एप्लिकेशन्स का मूल्यांकन करता है और ऑडिट-तैयार PDF/MD/JSON रिपोर्ट्स तैयार करता है।
- **[Open Policy Agent](https://www.openpolicyagent.org/)**: पॉलिसी इंजन।
- **[Regal](https://github.com/StyraInc/regal)**: वह Rego linter जिसका हम CI में उपयोग करते हैं।

---

## कम्युनिटी और सहायता

जवाब पाने के लिए Rego, OPA या GitHub की परंपराओं की जानकारी ज़रूरी नहीं है।

| आप क्या करना चाहते हैं | कहाँ जाएँ |
| --- | --- |
| अपने CI, OPA सर्वर या प्लैटफ़ॉर्म में GOPAL जोड़ने का तरीका पूछना | [इंटीग्रेशन सहायता फ़ॉर्म](https://github.com/Principled-Evolution/gopal/issues/new?template=integration_help.yml) या [Q&A डिस्कशन](https://github.com/Principled-Evolution/gopal/discussions/new?category=q-a) |
| ऐसे नियम या मानक की मांग करना जो GOPAL में अभी नहीं है | [नए फ़्रेमवर्क का अनुरोध](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml) |
| पहले से समर्थित फ़्रेमवर्क में किसी विशिष्ट पॉलिसी की मांग करना | [नई पॉलिसी का अनुरोध](https://github.com/Principled-Evolution/gopal/issues/new?template=new_policy.yml) |
| किसी पॉलिसी के गलत नतीजे की रिपोर्ट करना | [बग रिपोर्ट](https://github.com/Principled-Evolution/gopal/issues/new?template=bug_report.yml) |
| GitHub की जगह सीधे ईमेल करना | **gopal@principledevolution.ai** |
| सुरक्षा भेद्यता की रिपोर्ट करना | [SECURITY.md](SECURITY.md) देखें। कृपया सार्वजनिक issue न खोलें |

अनुरोध दर्ज करने से पहले दो जगहें ज़्यादातर सवालों का जवाब दे देती हैं। [कवरेज मैट्रिक्स](docs/coverage) अनुच्छेद-दर-अनुच्छेद बताता है कि क्या लागू हो चुका है, और [FAQ](docs/FAQ.md) दायरे, इनपुट फ़ॉर्मैट तथा AICertify से संबंध को समझाता है।

हर आकार का योगदान स्वागत योग्य है, [CONTRIBUTING.md](CONTRIBUTING.md) देखें। भागीदारी हमारी [आचार संहिता](CODE_OF_CONDUCT.md) के अंतर्गत आती है।

### इन सूचियों में शामिल

- [**awesome-opa**](https://github.com/open-policy-agent/awesome-opa), Open Policy Agent प्रोजेक्ट की अपनी क्यूरेटेड लिस्ट, Policy Packages सेक्शन में
- [**OPA इकोसिस्टम डायरेक्टरी**](https://www.openpolicyagent.org/ecosystem/entry/principled-evolution)
- [**Awesome Responsible AI**](https://github.com/AthenaCore/AwesomeResponsibleAI), Policy as Code सेक्शन में
- [**Awesome AI Agent Governance**](https://github.com/systempromptio/awesome-ai-agent-governance#policy-engines-and-authorisation), Policy Engines and Authorisation सेक्शन में

---

## लाइसेंस

Apache License 2.0, देखें [LICENSE](LICENSE)।

<p align="center"><sub><a href="https://github.com/Principled-Evolution">Principled Evolution</a> द्वारा अनुरक्षित · कंप्लायंस जिसे आप पढ़ सकते हैं, चला सकते हैं, और सिद्ध कर सकते हैं।</sub></p>
