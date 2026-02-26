# Snippet: Synthetic Data Generation

## Domain Context
Generating artificial data for training, augmentation, privacy preservation, or testing.
Synthetic data is a tool, not a shortcut — quality and fitness-for-purpose must be validated rigorously.

## When to Use Synthetic Data
- Insufficient real data: rare events, cold-start scenarios, new product categories
- Privacy constraints: regulated domains (healthcare, finance) where real data cannot be shared
- Data augmentation: supplementing real data to improve model robustness
- Testing & CI: generating realistic test fixtures without relying on production data
- **Always** justify why synthetic data is needed — real data is preferred when available

## Generation Methods
- **Rule-based**: deterministic templates + randomization — simple, fully controllable, but limited diversity
- **Statistical models**: fit distribution to real data, sample from it — good for tabular data
- **Generative models**: GANs, VAEs, diffusion models — for images, text, complex distributions
- **LLM-generated**: prompt-based text generation — powerful but requires quality filtering
- Document the generation method, parameters, and random seed for every synthetic dataset

## Quality Assurance
- **Fidelity check**: synthetic data distribution should match real data on key statistics
  - Tabular: column distributions, correlation matrix, conditional distributions
  - Text: length distribution, vocabulary coverage, topic distribution
  - Images: FID score against real data (lower is better)
- **Utility check**: model trained on synthetic data must approach performance of model trained on real data
- **Privacy check**: verify no memorization of real data — nearest neighbor distance analysis
- **Diversity check**: synthetic data should cover edge cases, not just repeat common patterns
- Reject synthetic datasets that fail any of these checks — don't use them "because we already generated them"

## LLM-Generated Data Specific
- Diversity enforcement: vary prompts, examples, and generation parameters to avoid repetitive outputs
- Quality filtering pipeline: generate N samples → filter to top K by quality score
- Decontamination: verify synthetic data doesn't overlap with evaluation benchmarks
- Bias amplification: LLMs can amplify biases from their training data — audit for fairness
- Cost tracking: log token usage and generation cost per synthetic sample

## Privacy-Preserving Synthetic Data
- Differential privacy guarantees: document ε (epsilon) value and what it means for your use case
- Membership inference test: verify that individual real records cannot be identified in synthetic data
- Attribute disclosure: check that rare attribute combinations aren't copied verbatim
- Train/test with real, validate synthetic pipeline on real → then deploy synthetic pipeline
- Regulatory compliance: confirm synthetic data approach meets GDPR/HIPAA requirements before use

## Integration with Training
- Mix ratio: start with 50% real + 50% synthetic; tune ratio based on downstream metrics
- Curriculum: consider training on synthetic first, then fine-tuning on real data
- Label the data source: synthetic vs. real — enables analysis of contribution to model performance
- Monitor training loss separately for real and synthetic batches — divergence signals quality issues
- Ablation: always compare model performance with and without synthetic data

## Common Pitfalls
- Mode collapse: generative model produces limited variety — check diversity metrics
- Distribution mismatch: synthetic data looks realistic but doesn't match real data's task-relevant patterns
- Over-reliance: synthetic data as a substitute for proper data collection, not a supplement
- Evaluation contamination: synthetic data generated from the same distribution as the test set
- Cost underestimation: generating high-quality synthetic data is not free — budget generation + filtering
