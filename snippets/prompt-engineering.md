# Snippet: Prompt Engineering

## Domain Context
Designing, testing, and iterating on prompts for LLM-powered features.
Prompts are code — they deserve the same versioning, testing, and review rigor.

## Prompt Design Principles
- Start with the simplest prompt that could work — add complexity only when eval shows it's needed
- Structure: `[System context] → [Task instruction] → [Format spec] → [Examples] → [Input]`
- Be explicit about what NOT to do — LLMs follow positive instructions better but need negative guardrails
- Specify output format precisely: JSON schema, bullet list, or exact template
- One task per prompt — if you need multiple steps, chain separate prompts

## Prompt Patterns (use by name in code comments)
- **Zero-shot**: direct instruction, no examples — baseline for every task
- **Few-shot**: 3-5 diverse examples covering edge cases — most reliable improvement
- **Chain-of-Thought (CoT)**: "Think step by step" — effective for reasoning tasks
- **Self-Consistency**: run CoT multiple times, majority vote — improves accuracy at higher cost
- **ReAct**: interleave reasoning + tool actions — for tasks requiring external information
- **Structured Output**: force JSON/XML schema — essential for downstream parsing

## Version Control
- Every prompt must have a version identifier: `{task}_v{N}_{model}`
- Store prompts in dedicated files (YAML, Jinja2, or .txt) — never inline in application code
- Track prompt changes in git with meaningful commit messages explaining the change reason
- Maintain a prompt changelog: what changed, why, and eval results before/after

## Testing & Evaluation
- Every prompt change must be evaluated on a held-out test set (minimum 50 examples)
- Define pass/fail criteria BEFORE writing the prompt — not after seeing results
- Test edge cases explicitly: empty input, very long input, adversarial input, multilingual
- A/B test prompts in production with traffic splitting — offline eval is necessary but insufficient
- Log prompt performance over time — model updates can silently degrade prompt effectiveness

## Optimization Techniques
- Token efficiency: remove unnecessary words, use concise instructions — cost scales with tokens
- Temperature tuning: 0 for deterministic tasks, 0.3-0.7 for creative tasks, document the choice
- Few-shot example selection: choose examples similar to expected input distribution
- Dynamic few-shot: retrieve relevant examples per query rather than fixed examples
- Prompt compression: for long contexts, summarize or extract key information before feeding to model

## System Prompt Best Practices
- Define role, tone, constraints, and output format in the system prompt
- Keep system prompts stable — change task prompts, not system prompts, for iteration
- Include explicit safety constraints: what topics to refuse, what data not to expose
- Test system prompt robustness against prompt injection attempts

## Common Pitfalls
- Prompt sensitivity: minor wording changes cause major output differences — always eval
- Example bias: few-shot examples that are too similar cause the model to parrot patterns
- Instruction following degrades with context length — put critical instructions at start AND end
- Model-specific prompts: a prompt optimized for GPT-4 may perform poorly on Claude or Llama
- Forgetting to update prompts when the model version changes
