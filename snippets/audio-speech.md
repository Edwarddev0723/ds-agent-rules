# Snippet: Audio & Speech Processing

## Domain Context
Automatic Speech Recognition (ASR), Text-to-Speech (TTS), speaker identification, audio classification.
Audio has unique challenges: variable length, noise sensitivity, real-time requirements.

## Data Pipeline
- Audio format standardization: convert all inputs to consistent sample rate (16kHz for ASR, 22kHz+ for TTS)
- Validate audio on ingest: check for corruption, silence-only files, anomalous duration (too short/too long)
- Noise profiling: categorize training data by SNR level; log noise distribution before training
- Always store raw audio — preprocessing should be reproducible from source
- For speech data: check language, accent, and speaker distribution — imbalance here causes production failures

## ASR (Speech-to-Text)
- Baseline: use Whisper (large-v3) zero-shot before fine-tuning anything
- Metric: Word Error Rate (WER) as primary; Character Error Rate (CER) for languages without clear word boundaries
- Evaluate WER by: noise level, speaker accent, audio length, domain vocabulary
- Decoder configuration: document beam size, language model weight, and any post-processing rules
- Punctuation and casing: handle as post-processing unless the model does it natively — document the approach

## TTS (Text-to-Speech)
- Evaluation requires human listening tests — MOS (Mean Opinion Score) on 1-5 scale
- Supplement human eval with: speaker similarity (for voice cloning), intelligibility, naturalness
- Prosody control: test on edge cases — numbers, abbreviations, foreign words, emotional text
- Latency: measure time-to-first-audio for streaming TTS; total generation time for batch
- Always test on long-form text (>500 words) — many models degrade on longer inputs

## Audio Classification
- Feature extraction: log-mel spectrograms as default input representation
- Augmentation: time stretch, pitch shift, noise injection, SpecAugment — document the pipeline
- Class balance is critical: audio datasets are often heavily skewed — stratified splits required
- Window size and hop length: document and keep consistent between training and inference
- Real-time classification: profile latency per audio chunk, not per full clip

## Production Deployment
- Streaming ASR: measure Real-Time Factor (RTF) — must be <1.0 for real-time applications
- VAD (Voice Activity Detection): implement before ASR to avoid processing silence/noise
- Endpointing: detect when the speaker has finished — crucial for conversational AI latency
- Fallback: define behavior for unsupported languages, excessive noise, or very long audio
- Privacy: implement PII detection in transcriptions; offer on-device processing for sensitive audio

## Common Pitfalls
- Sample rate mismatch between training and inference — causes silent degradation
- Microphone variability: models trained on studio audio fail on phone/laptop microphones
- Background music in speech data: ASR models struggle without explicit noise robustness training
- Evaluation only on clean audio: real-world WER is typically 2-5x worse than clean benchmarks
- Ignoring speaker diversity: models can be biased toward specific accents, genders, or age groups
