# Snippet: Responsible AI & Safety

## Domain Context
Ensuring AI systems are fair, safe, transparent, and accountable.
These rules apply to any model that affects people — which is nearly all of them.

## Bias & Fairness
- Define protected attributes upfront (age, gender, ethnicity, etc.) — document which ones are relevant and why
- Measure fairness metrics across protected groups using AIF360 or Fairlearn:
  - Demographic parity difference (< 0.1 for low-risk, < 0.05 for high-risk applications)
  - Equalized odds difference (< 0.1)
  - Calibration: prediction means should be within 5% across groups
- Disparate impact check: any metric gap >20% across groups requires investigation and documentation
- Training data audit: check for representation imbalance and historical bias before training — log group counts
- If debiasing is applied, document the method (resampling, reweighting, adversarial) and its impact on overall performance
- Intersectional analysis: check bias across combinations of protected attributes (e.g., age × gender), not just individual axes
- Run bias evaluation on a held-out slice analysis set — never reuse the general test set for fairness audits

## Safety Guardrails
- All user-facing models must have output filtering: toxicity (Perspective API / Detoxify, threshold > 0.7 = block), PII (Presidio), harmful content
- Input validation: detect and reject adversarial inputs, prompt injections (rebuff / LLM-Guard), out-of-distribution queries
- Define a "refuse to answer" policy — model should abstain rather than produce harmful output; document the refusal categories
- Maintain a safety test suite: ≥100 adversarial prompts covering toxicity, bias, PII leakage, jailbreaks — version-controlled
- Regular red-team testing: quarterly at minimum for production systems, with documented findings and remediation timeline
- Toxicity threshold: block outputs scoring >0.7 on Perspective API; flag for human review at >0.5
- Rate limiting: cap per-user requests to prevent abuse (e.g., 60 req/min for general use, stricter for generation endpoints)
- Content classifiers must be updated quarterly — new attack patterns emerge faster than model update cycles

## Transparency & Explainability
- Document model limitations explicitly — what the model CANNOT do is as important as what it can
- Provide explanations appropriate to the audience: SHAP/LIME for data scientists, plain language for end users
- Model cards: every production model must have one — include intended use, limitations, performance by demographic group, training data summary
- Decision audit trail: for high-stakes decisions (credit, hiring, medical), log inputs, model version, outputs, and explanations — retain for ≥2 years
- Confidence/uncertainty: expose prediction confidence to downstream consumers; define a minimum confidence threshold (e.g., 0.7) below which the model defers to human judgment
- Watermarking: for generative models, consider output watermarking for traceability (e.g., text watermarking via green/red token lists)

## Data Privacy
- PII detection and redaction in training data — automated scan (Presidio or custom regex) before any training run
- Data retention policy: define how long model inputs/outputs are stored; default to 90 days unless compliance requires longer
- Right to deletion: ensure ability to remove individual's data and retrain if requested; document the DSAR process
- Synthetic data: consider for sensitive domains — document the generation method, privacy guarantees, and fidelity metrics
- Federated learning: evaluate when data cannot leave its origin for regulatory reasons
- Differential privacy: for sensitive training data, use DP-SGD with ε ≤ 10 and document the privacy budget

## Governance & Documentation
- Risk assessment for every new model: who is affected, what can go wrong, mitigations, residual risk acceptance
- Incident response plan: what happens when the model produces harmful output in production — define SLA (e.g., <4hr for severity-1)
- Regular model reviews: scheduled re-evaluation of fairness metrics and performance drift — at minimum every 6 months
- Regulatory compliance: identify applicable regulations (GDPR, EU AI Act, CCPA, sector-specific) at project start
- Stakeholder communication: non-technical summary of model behavior, risks, and limitations — update with each release
- AI system inventory: maintain a registry of all deployed models with ownership, risk level, and review schedule

## Testing & Monitoring
- A/B testing: include fairness metrics in experiment dashboards, not just engagement/revenue
- Production monitoring: alert on fairness metric drift — set threshold at 1.5× the training-time gap
- Shadow scoring: run bias assessments on live traffic samples weekly, not just at deploy time
- Regression testing: every model update must re-run the safety test suite — automate in CI; gate deployment on pass
- User feedback loop: provide a mechanism for users to report biased or harmful outputs; track resolution rate (target: 100% triaged within 48hr)
- Hallucination monitoring (generative models): sample ≥100 production outputs/week for factual accuracy audit

## Accessibility
- Model outputs must be compatible with screen readers — avoid emoji-heavy or ASCII art responses
- For multi-language models, test outputs across all supported languages — quality often varies 20–40%
- Color-dependent visualizations (e.g., SHAP plots) must be colorblind-safe — use viridis or cividis palettes
- Provide alternative text for any model-generated images or charts

## Common Pitfalls
- "The model is unbiased because we removed protected attributes" — proxy variables (zip code → race) still exist
- Fairness metrics can conflict with each other (demographic parity vs. equalized odds) — document which ones you prioritize and why
- Safety testing only at launch, never revisited — models face new attack vectors over time; schedule recurring audits
- Explainability as afterthought — design for interpretability from the start; retrofitting is 5× more expensive
- Assuming open-source model = safe model — independent safety evaluation is still required
- Over-reliance on automated toxicity classifiers — they miss context-dependent harm and cultural nuance; human review is mandatory for edge cases
- Treating responsible AI as a one-time checklist instead of a continuous process — embed it in sprint workflows
