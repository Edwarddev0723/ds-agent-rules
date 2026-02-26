# Research Project Overlay
> Appended on top of core.md for research-focused projects (papers, datasets, benchmarks).

## Project Mindset
The goal is producing **verifiable, publishable findings**.
Prioritize: rigor, documentation of negative results, and full reproducibility.
Every experiment should be runnable by someone else without asking you.

---

## Documentation Standards
- Every experiment folder must contain a `README.md` explaining: goal, method, results
- Document **failed** experiments — negative results prevent duplicated effort
- Keep a `CHANGELOG.md` or experiment log with dated entries
- All non-obvious design decisions must have written justification
- Maintain a running `NOTES.md` for daily research observations and hypotheses

---

## Reproducibility Requirements
- Provide a single command to reproduce any reported result
- `environment.yml` or `Dockerfile` must be kept up to date
- All random seeds must be fixed AND reported in documentation
- Dataset versions must be pinned (hash or version tag)
- Hardware specs (GPU model, VRAM, CUDA version) logged for every experiment
- Log wall-clock time and GPU hours for every experiment — reviewers increasingly ask for compute budgets

---

## Literature & Prior Art
- Maintain a `references.bib` — add entries before citing, not after
- When implementing a baseline from a paper, link the source paper and note any deviations
- Track concurrent work: check arXiv weekly for overlapping publications
- Every related work mentioned must have a citation — never leave placeholder "[TODO]"

---

## Paper / Report Writing Support
- When helping draft text, maintain academic tone — precise, passive where appropriate
- Flag claims that need citations
- Distinguish clearly between: our contribution vs. prior work vs. concurrent work
- Equations should be verified for correctness before inclusion
- Use consistent notation throughout — define symbols in a notation table
- Figures: vector format (PDF/SVG) for diagrams, PNG for screenshots, minimum 300 DPI

---

## Ablation Study Guidelines
- Change one variable at a time
- Keep all other conditions identical across ablation runs
- Results table must include: metric, seed count, compute cost
- Report statistical significance: p-values or confidence intervals for key comparisons
- Include both the ablation table and a brief interpretation paragraph

---

## Dataset & Benchmark Release
- Provide a `datasheet` or `data card` describing: source, collection method, intended use, limitations
- Include a license file specifying usage terms
- De-identify data before release — automated PII scan required
- Provide train/val/test split files — never leave splitting to the user
- Include baseline results so others can verify their setup
