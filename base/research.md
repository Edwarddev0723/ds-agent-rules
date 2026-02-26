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

---

## Reproducibility Requirements
- Provide a single command to reproduce any reported result
- `environment.yml` or `Dockerfile` must be kept up to date
- All random seeds must be fixed AND reported in documentation
- Dataset versions must be pinned (hash or version tag)

---

## Paper / Report Writing Support
- When helping draft text, maintain academic tone — precise, passive where appropriate
- Flag claims that need citations
- Distinguish clearly between: our contribution vs. prior work vs. concurrent work
- Equations should be verified for correctness before inclusion

---

## Ablation Study Guidelines
- Change one variable at a time
- Keep all other conditions identical across ablation runs
- Results table must include: metric, seed count, compute cost
