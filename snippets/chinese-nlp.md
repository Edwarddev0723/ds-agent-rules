# Snippet: Traditional Chinese NLP / Taiwan-Specific

## Domain Context
This project processes Traditional Chinese (繁體中文) text, targeting Taiwan audiences.
Simplified Chinese output is always incorrect in this context.

## Language Rules
- Output Traditional Chinese (繁體中文) only — Simplified Chinese is always wrong here
- Use Taiwan-standard terminology, not China/Hong Kong variants when they differ
  - e.g., 軟體 not 软件, 資料 not 数据, 網路 not 网络, 程式 not 程序, 伺服器 not 服务器
- For Taiwan-specific cultural content, prefer human review over automated validation
- Prefer Taiwan locale (zh-TW) in all i18n/l10n settings
- Number formatting: use 萬/億 (not K/M) in user-facing text; use standard numerals in code/logs

## Tokenization
- Never assume character-level tokenization is sufficient — use proper TC tokenizers
- Recommended: ckip-transformers (Albert-based) for segmentation + POS + NER — accuracy ≥ 95% on ASBC
- Test tokenizer output on Taiwan-specific named entities before committing
- Validate against mixed TC/English text (common in Taiwan tech content): "使用 Python 來處理 NLP 任務"
- CJK punctuation differs from ASCII — handle fullwidth characters: 「」、，。！？（）
- Sentence splitting: use `。！？` as primary delimiters; `\n` as fallback — do not split on `,` or `、`

## Model Selection Heuristics
- Prefer models with TC pretraining data: CKIP-BERT, Breeze-7B, Taiwan-LLM, MediaTek MR series, Llama-3-Taiwan
- When using multilingual models (mBERT, XLM-R, mT5), verify TC performance explicitly — TC often 10–20% below EN
- Document language distribution of training data for any fine-tuned model
- For embeddings, test retrieval quality on TC queries specifically — multilingual models often score 15–30% lower R@10 than dedicated TC models
- For generative tasks: evaluate with native speakers, not just automated metrics — fluency issues invisible to BLEU

## Data Preprocessing
- Convert all Simplified Chinese input to Traditional Chinese before processing (use OpenCC with `s2twp` config for Taiwan phrases)
- Normalize Unicode forms: NFKC for consistent handling of fullwidth characters
- Handle Bopomofo (注音) in user-generated content — do not strip or mangle it
- Common crawl data often mixes TC/SC — apply `langdetect` per paragraph, not per document (error rate < 5% at paragraph level)
- Remove zero-width characters (U+200B, U+FEFF) — common in web-scraped TC text, breaks tokenization
- For datasets with Pinyin annotations, separate Pinyin from TC text in preprocessing — mixing confuses tokenizers

## Evaluation
- Use TC-specific benchmarks when available: DRCD for QA (F1 ≥ 0.80 is strong), ASBC for segmentation, CKIP NER
- Never evaluate TC output using Simplified Chinese metrics or tokenizers
- Manual evaluation by a native TC speaker is required for any production-facing output
- BLEU/ROUGE on TC requires TC-aware tokenization (jieba-tw or ckip) — default whitespace split is meaningless
- For generation tasks, use character-level F1 in addition to token-level metrics — BPE boundaries differ across tokenizers
- Report character error rate (CER) alongside word error rate for ASR/OCR tasks — CER < 5% is production-ready for TC

## Search & Retrieval
- Embedding models: benchmark on TC query–document pairs from your domain — do not trust English-only benchmarks
- For keyword search, implement both Traditional and Simplified Chinese query expansion (users may paste SC content)
- Stopword lists: use TC-specific stopword lists, not general Chinese ones — 的、了、是 frequencies differ by locale
- Query segmentation: run ckip-transformers on queries before BM25 — unsegmented CJK text kills recall (30–50% drop)
- Hybrid search (BM25 + dense) is especially important for TC — dense models underperform more on CJK than on English

## Regulatory & Cultural
- Personal data handling must comply with Taiwan PDPA (個人資料保護法) — PII detection must cover Taiwan ID formats (A123456789), phone numbers (+886-XX-XXXX-XXXX), and addresses
- Content moderation: Taiwan-specific slang and colloquialisms require culturally aware classifiers
- Date formats: prefer 民國 year format (e.g., 115年) for government/official contexts, ISO 8601 for technical logs
- Currency: 新台幣 / NT$ — do not use ¥ or RMB symbols for Taiwan contexts

## Common Pitfalls
- OpenCC `s2t` is not enough for Taiwan — use `s2twp` (Taiwan phrases) to avoid Mainland phrasing like 信息→資訊, 軟件→軟體
- Many "Chinese" datasets are actually SC-only — verify script distribution before claiming TC coverage
- Sentence boundary detection: `。` is the primary sentence-ender, not period (`.`)
- NER models trained on SC corpora miss Taiwan-specific entities (place names, politician names, brands)
- Token count differs significantly between TC and English — budget 2–3× more tokens for equivalent TC content
- Fonts matter for OCR: 標楷體 (DFKai-SB) and 新細明體 are common TC fonts — train/test on them specifically
