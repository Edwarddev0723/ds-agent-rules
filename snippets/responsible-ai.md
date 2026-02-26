# Snippet: Responsible AI & Safety

## Domain Context
Ensuring AI systems are fair, safe, transparent, and accountable.
These rules apply to any model that affects people — which is nearly all of them.

## Bias & Fairness
- Define protected attributes upfront (age, gender, ethnicity, etc.) — document which ones are relevant
- Measure fairness metrics across protected groups: demographic parity, equalized odds, etc.
- Disparate impact check: any metric gap >20% across groups requires investigation and documentation
- Training data audit: check for representation imbalance and historical bias before training
- If debiasing is applied, document the method and its impact on overall performance

## Safety Guardrails
- All user-facing models must have output filtering: toxicity, PII, harmful content
- Input validation: detect and reject adversarial inputs, prompt injections, out-of-distribution queries
- Define a "refuse to answer" policy — model should abstain rather than produce harmful output
- Maintain a safety test suite: adversarial prompts, edge cases, known failure modes
- Regular red-team testing: quarterly at minimum for production systems

## Transparency & Explainability
- Document model limitations explicitly — what the model CANNOT do is as important as what it can
- Provide explanations appropriate to the audience: SHAP for data scientists, plain language for users
- Model cards: every production model should have one (intended use, limitations, performance by group)
- Decision audit trail: for high-stakes decisions, log inputs, model version, outputs, and explanations
- Confidence/uncertainty: expose prediction confidence to downstream consumers when possible

## Data Privacy
- PII detection and redaction in training data — automated scan before any training run
- Data retention policy: define how long model inputs/outputs are stored
- Right to deletion: ensure ability to remove individual's data and retrain if requested
- Synthetic data: consider for sensitive domains — document the generation method and privacy guarantees
- Federated learning: evaluate when data cannot leave its origin for regulatory reasons

## Governance & Documentation
- Risk assessment for every new model: who is affected, what can go wrong, what's the mitigation
- Incident response plan: what happens when the model produces harmful output in production
- Regular model reviews: scheduled re-evaluation of fairness metrics and performance drift
- Regulatory compliance: identify applicable regulations (GDPR, AI Act, etc.) at project start
- Stakeholder communication: non-technical summary of model behavior, risks, and limitations

## Common Pitfalls
- "The model is unbiased because we removed protected attributes" — proxies still exist
- Fairness metrics can conflict with each other — document which ones you prioritize and why
- Safety testing only at launch, never revisited — models face new attack vectors over time
- Explainability as afterthought — design for interpretability from the start
- Assuming open-source model = safe model — independent safety evaluation is still required
