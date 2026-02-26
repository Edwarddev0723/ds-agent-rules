# Snippet: Data Labeling & Annotation Quality

## Domain Context
Managing the data labeling lifecycle: guideline creation, annotator coordination, quality assurance.
Model quality ceiling = label quality. No model can fix bad labels.

## Labeling Guidelines
- Write annotation guidelines BEFORE any labeling begins — iterate them, not ad-hoc corrections
- Guidelines must include: task definition, label taxonomy, edge case examples, and "when in doubt" rules
- Include at least 5 positive and 5 negative examples per label category
- Version control the guidelines — annotators must always use the latest version
- When guidelines change, re-label a sample of previously labeled data for consistency

## Quality Metrics
- **Inter-Annotator Agreement (IAA)**: compute before using any labels for training
  - Cohen's Kappa ≥ 0.7 for binary; Fleiss' Kappa ≥ 0.6 for multi-annotator
  - If IAA is low, the task definition is ambiguous — fix guidelines, not annotators
- **Gold standard sets**: maintain a curated set of 100+ expert-labeled examples for calibration
- Every annotator batch must include 10-15% hidden gold standard items for ongoing quality monitoring
- Track per-annotator accuracy — remove or retrain consistently underperforming annotators

## Labeling Workflow
- **Pilot round**: label 50-100 items, compute IAA, refine guidelines, repeat until threshold met
- **Production round**: assign 2-3 annotators per item for critical tasks; majority vote for labels
- **Adjudication**: disagreements on critical items must be resolved by expert review, not majority vote
- Log annotation metadata: annotator ID, timestamp, time spent per item, tool version
- Implement annotator calibration sessions: regular alignment meetings on ambiguous cases

## Active Learning Integration
- Start with random sampling, switch to uncertainty sampling after initial model is trained
- Query strategies: uncertainty, diversity, or committee disagreement — document the choice
- Human review budget: define how many items can be labeled per iteration (fixed budget)
- Re-evaluate model after each active learning cycle — track diminishing returns
- Stop criteria: when adding more labels provides <1% metric improvement

## Data Pipeline Integration
- Raw annotations → cleaned annotations → final labels: maintain all three versions
- Label format: use standard formats (COCO for vision, IOB2 for NER, etc.)
- Track label distribution throughout the pipeline — flag unexpected class imbalance shifts
- Deduplication: ensure the same item is not labeled multiple times (unless for IAA computation)
- PII review: check labeled data for inadvertent personal information before use

## Common Pitfalls
- Labeler fatigue: quality degrades after 2-3 hours of continuous labeling — enforce breaks
- Majority class bias: annotators default to the most common label when uncertain
- Guideline drift: annotators gradually reinterpret guidelines without explicit correction
- Sampling bias: items sent for labeling don't represent the production data distribution
- Ignoring disagreement: low IAA items carry noisy labels that confuse models — handle explicitly
