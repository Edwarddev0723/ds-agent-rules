# ds-agent-rules

[![CI](https://github.com/Edwarddev0723/ds-agent-rules/actions/workflows/ci.yml/badge.svg)](https://github.com/Edwarddev0723/ds-agent-rules/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/ds-agent-rules)](https://www.npmjs.com/package/ds-agent-rules)
[![PyPI version](https://img.shields.io/pypi/v/ds-agent-rules)](https://pypi.org/project/ds-agent-rules/)
[![GitHub release](https://img.shields.io/github/v/release/Edwarddev0723/ds-agent-rules)](https://github.com/Edwarddev0723/ds-agent-rules/releases)
[![GitHub stars](https://img.shields.io/github/stars/Edwarddev0723/ds-agent-rules?style=social)](https://github.com/Edwarddev0723/ds-agent-rules/stargazers)

> **[English README](README.md)**

一套可攜式、可組合的 AI 程式碼代理規則系統 — 為**資料科學、機器學習與 AI 工程**專案提供單一規則來源。

撰寫一次規則，同步至 **Claude Code · GitHub Copilot · OpenAI Codex · Gemini Code · Cursor · Windsurf** — 一次搞定。

---

## 解決什麼問題？

沒有明確規則的 AI 代理，會靜悄悄地引入壞習慣：

| 常見問題 | 影響 |
|---------|------|
| 未設定隨機種子 | 實驗無法重現 |
| 時間序列資料用隨機分割 | 資料洩漏 |
| 跳過 baseline 評估 | 模型效果無法驗證 |
| 超參數寫死在程式碼裡 | 實驗無法追蹤 |

**ds-agent-rules** 透過分層、可組合的規則系統，讓每個 AI 工具保持一致的行為。

---

## 運作原理

```
 ┌────────────────────┐
 │   base/core.md     │  ← 永遠載入
 │   base/ds-ml.md    │  ← 專案類型疊加層
 │   snippets/rag.md  │  ← 領域專屬規則
 │   team/*.md        │  ← 團隊覆寫（選用）
 └────────┬───────────┘
          │  sync.sh
          ▼
 ┌────────────────────────────────────┐
 │  CLAUDE.md                        │
 │  AGENTS.md                        │
 │  .github/copilot-instructions.md  │
 │  .gemini/styleguide.md            │
 │  .cursorrules                     │
 │  .windsurfrules                   │
 └────────────────────────────────────┘
```

**分層模型：** `core`（必載）→ `overlay`（專案類型）→ `snippets`（領域模組）→ `team`（團隊覆寫）

---

## 快速開始

### 1. 安裝

選擇你喜歡的方式：

```bash
# npm（透過 npx 零安裝）
npx ds-agent-rules init

# pip
pip install ds-agent-rules
ds-agent-rules init

# git clone（完整控制）
git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules
cd ~/.ai-rules && chmod +x sync.sh new-project.sh
```

### 2. 選擇設定方式

<details>
<summary><b>A) npx / pip</b> — 免 clone 工作流</summary>

```bash
cd /path/to/your/project
npx ds-agent-rules preset llm-project    # npm
ds-agent-rules preset llm-project        # pip

# 或使用互動式
npx ds-agent-rules new-project
```
</details>

<details>
<summary><b>B) 互動式設定</b>（git clone）— 引導式問答</summary>

```bash
cd /path/to/your/project
~/.ai-rules/new-project.sh
```

自動建立 `.ai-rules.yaml`、同步規則、產生目錄結構。
</details>

<details>
<summary><b>B) 一行指令搭配 preset</b> — 最快的方式</summary>

```bash
cd /path/to/your/project
~/.ai-rules/sync.sh --preset llm-project
```
</details>

<details>
<summary><b>C) 設定檔</b> — 推薦給持續開發的專案</summary>

```bash
cd /path/to/your/project
~/.ai-rules/sync.sh --init          # 建立 .ai-rules.yaml 範本
vim .ai-rules.yaml                   # 依專案需求編輯
~/.ai-rules/sync.sh                  # 同步（自動讀取設定檔）
```
</details>

### 3. 常用指令

```bash
./sync.sh --list                     # 列出所有疊加層、片段、預設組合
./sync.sh --dry-run ds-ml rag        # 預覽，不寫入檔案
./sync.sh --diff                     # 顯示 unified diff 開始套用前的變更
./sync.sh --validate                 # 檢查專案結構是否符合規則
./sync.sh --output-dir /other/proj   # 寫入至其他專案
./sync.sh --team ./team-rules        # 載入團隊專屬規則
```

### 4. Make 指令

```bash
make help                            # 顯示所有可用的 target
make lint                            # 執行 ShellCheck 檢查所有腳本
make test                            # 執行 bats 測試套件
make validate                        # 驗證目前專案
make ci                              # lint + test（與 CI 相同）
```

---

## 專案結構

```
ds-agent-rules/
├── base/                    # 專案類型疊加層
│   ├── core.md              # 通用規則（永遠載入）
│   ├── ds-ml.md             # 資料科學 / 機器學習
│   ├── llm-eng.md           # LLM / 生成式 AI 工程
│   ├── data-eng.md          # 資料工程
│   ├── software-eng.md      # 傳統軟體工程
│   └── research.md          # 研究 / 學術
│
├── snippets/                # 領域專屬規則模組（自由組合）
│   ├── agentic-ai.md        # AI 代理與工具使用
│   ├── audio-speech.md      # 語音辨識 / 語音合成 / 音訊分類
│   ├── chinese-nlp.md       # 繁體中文 NLP
│   ├── ctr-prediction.md    # CTR / 推薦系統
│   ├── cv.md                # 電腦視覺
│   ├── data-labeling.md     # 標註品質與主動學習
│   ├── distributed-training.md  # 多 GPU/節點訓練 (DeepSpeed, FSDP)
│   ├── edge-inference.md    # 行動裝置 / 邊緣部署
│   ├── evaluation-framework.md  # 系統化評估
│   ├── graph-ml.md          # 圖神經網路
│   ├── jax.md               # JAX / Flax
│   ├── llm-finetuning.md    # LLM 微調 (LoRA, RLHF)
│   ├── mlops.md             # MLOps 與部署
│   ├── nlp-general.md       # 通用 NLP
│   ├── prompt-engineering.md    # 提示詞設計與版本管理
│   ├── pytorch.md           # PyTorch
│   ├── rag.md               # RAG 管線
│   ├── responsible-ai.md    # 負責任 AI 與安全
│   ├── streaming-ml.md      # 線上學習與串流推論
│   ├── synthetic-data.md    # 合成資料與隱私
│   ├── tabular-ml.md        # 表格式 ML
│   ├── time-series.md       # 時間序列預測
│   └── vlm.md               # 視覺語言模型
│
├── presets/                  # 具名預設組合（一鍵設定，15 組預設）
├── templates/                # 各專案類型的目錄鷹架（5 個模板）
├── tests/                    # bats 測試套件
│   └── sync.bats
├── .github/
│   ├── workflows/ci.yml      # CI（ShellCheck + bats，ubuntu & macos）
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/       # Issue 模板（新增 snippet、Bug 回報）
├── sync.sh                   # 主要同步腳本
├── new-project.sh            # 互動式專案初始化器
├── Makefile                  # make lint / test / validate / ci
├── CONTRIBUTING.md           # 貢獻指南與 snippet 格式規範
├── CHANGELOG.md              # 版本變更紀錄
└── README.md
```

---

## 預設組合 (Presets)

> 執行 `./sync.sh --list` 查看本地所有預設組合。

| 預設名稱 | 疊加層 | 包含的片段 |
|---------|--------|-----------|
| `llm-project` | ds-ml | llm-finetuning, rag, mlops, responsible-ai |
| `agentic-ai` | llm-eng | agentic-ai, prompt-engineering, rag, mlops, responsible-ai |
| `distributed-llm` | ds-ml | llm-finetuning, distributed-training, pytorch, mlops |
| `cv-project` | ds-ml | cv, mlops |
| `recsys-project` | ds-ml | ctr-prediction, tabular-ml, mlops |
| `tabular-project` | ds-ml | tabular-ml, mlops |
| `ts-forecast` | ds-ml | time-series, mlops |
| `nlp-project` | ds-ml | nlp-general, evaluation-framework, mlops |
| `research-llm` | research | llm-finetuning, rag, responsible-ai |
| `full-stack-ai` | llm-eng | llm-finetuning, rag, mlops, responsible-ai |
| `data-platform` | data-eng | streaming-ml, mlops |
| `graph-ml-project` | ds-ml | graph-ml, evaluation-framework, mlops |
| `labeling-project` | ds-ml | data-labeling, evaluation-framework, responsible-ai |
| `edge-deploy` | ds-ml | edge-inference, pytorch, mlops |
| `vlm-project` | ds-ml | vlm, cv, llm-finetuning, evaluation-framework |

---

## 設定方式

### `.ai-rules.yaml`（專案層級設定檔）

放在專案根目錄，`sync.sh` 會自動偵測。

```yaml
profile: ds-ml
snippets:
  - llm-finetuning
  - rag
  - pytorch
  - mlops

# team_dir: ./team-rules     # 選用：團隊規則目錄
# preset: llm-project        # 選用：改用預設組合
```

### 團隊規則

在 snippets 之後附加團隊專屬的 `.md` 規則：

```bash
mkdir team-rules && vim team-rules/our-standards.md

# 透過 CLI
./sync.sh --team ./team-rules ds-ml rag

# 或在 .ai-rules.yaml 中設定
# team_dir: ./team-rules
```

---

## 擴充方式

| 動作 | 指令 |
|------|------|
| **新增疊加層** | `cp base/ds-ml.md base/my-type.md` → 編輯 → `./sync.sh my-type` |
| **新增片段** | 建立 `snippets/my-domain.md` → `./sync.sh ds-ml my-domain` |
| **新增預設組合** | `echo "ds-ml my-domain mlops" > presets/my-preset.txt` |
| **更新規則** | 編輯片段 → `./sync.sh` → `git commit` |

---

## 安裝與 Git 策略

```bash
# 方式一：npm（推薦 JS/TS 開發者）
npm install -g ds-agent-rules
npx ds-agent-rules sync ds-ml rag    # 或透過 npx 直接執行

# 方式二：pip（推薦 Python 開發者）
pip install ds-agent-rules
ds-agent-rules sync ds-ml rag

# 方式三：獨立 clone
git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules

# 方式四：作為 dotfiles 的 Git submodule
cd ~/.dotfiles && git submodule add https://github.com/Edwarddev0723/ds-agent-rules
```

### 要把產生的檔案 commit 嗎？

| 情境 | 建議 |
|------|------|
| 個人 / 單人專案 | 加入 `.gitignore`，用 `sync.sh` 重新產生即可 |
| 團隊專案 | Commit — 確保團隊 AI 代理行為一致 |
| 開源專案 | Commit — 同時作為貢獻者的上手文件 |

---

## 推薦工作流程

```bash
# 1. 建立新專案
mkdir my-project && cd my-project && git init

# 2. 初始化（任選一種）
~/.ai-rules/new-project.sh              # 互動式
~/.ai-rules/sync.sh --preset llm-project # 一行搞定
~/.ai-rules/sync.sh --init              # 設定檔模式

# 3. 正常使用 AI 工具 — 會自動讀取產生的檔案

# 4. 驗證專案結構
~/.ai-rules/sync.sh --validate

# 5. 累積新經驗 → 更新規則
vim ~/.ai-rules/snippets/rag.md
~/.ai-rules/sync.sh
cd ~/.ai-rules && git add -A && git commit -m "rule: ..."
```

---

## AI 工具 → 檔案對照表

| AI 工具 | 設定檔 |
|--------|--------|
| Claude Code | `CLAUDE.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| OpenAI Codex / ChatGPT | `AGENTS.md` |
| Google Gemini Code | `.gemini/styleguide.md` |
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |

---

## 貢獻指南

歡迎貢獻！請參考 [CONTRIBUTING.md](CONTRIBUTING.md) 了解：
- Snippet 格式規範與品質標準
- Preset 與 overlay 格式
- Commit 慣例
- PR 檢查清單

---

## 版本變更紀錄

請參考 [CHANGELOG.md](CHANGELOG.md) 查看版本歷史。

---

## 授權條款

[MIT](LICENSE)
