# Recipe: AI Agent System

> **Use Case**: This configuration is designed for projects building multi-agent systems, tool-using LLMs, or autonomous AI pipelines. It addresses common failure modes like uncontrolled tool loops, missing retry logic, unsafe tool invocations, and untracked agent state.

## Configuration (`.ai-rules.yaml`)

Copy the following into your project's root `.ai-rules.yaml`:

```yaml
profile: llm-eng
snippets:
  - agentic-ai
  - prompt-engineering
  - mlops
```

## Why this stack?

**`llm-eng` (profile)**: LLM Engineering overlay provides the foundational standards for building reliable LLM-powered systems, including structured output validation, error budgets, and observability hooks.

**`agentic-ai`**: Enforces critical agent safety rules — bounded tool call loops, explicit plan-then-act patterns, deterministic rollback on failure, and mandatory human-in-the-loop checkpoints for high-stakes actions.

**`prompt-engineering`**: Ensures that all system prompts for agents are version-controlled and tested. Prevents accidental behavior changes when iterating on agent instructions, and enforces explicit tool-use schemas in prompts.

**`mlops`**: Brings production discipline to agent deployments — requiring structured logging of all agent decisions, latency monitoring per tool call, and experiment tracking for agent configuration changes.
