# Snippet: Graph ML & Knowledge Graphs

## Domain Context
Graph Neural Networks (GNN), knowledge graph reasoning, network analysis, and graph-based recommendations.
Graph structures add relational context that flat features miss — but also add significant complexity.

## Data Representation
- Define node types, edge types, and their attributes clearly before any modeling
- For heterogeneous graphs: document the full schema (node types × edge types × attribute types)
- Graph statistics to log before training: node count, edge count, degree distribution, connected components
- Handle isolated nodes explicitly — they receive no message passing information
- Temporal graphs: maintain edge timestamps; use temporal-aware splitting (no future edges in training)

## Model Selection
- Baseline: node/edge features + classical ML (without graph structure) establishes the GNN value-add
- GCN/GraphSAGE: start here for homogeneous node classification
- R-GCN/HGT: for heterogeneous graphs with multiple node/edge types
- GAT/GATv2: when attention-weighted neighborhood aggregation is expected to help
- Number of layers: 2-3 is usually optimal — more layers cause over-smoothing; document layer count choice

## Training Practices
- Neighbor sampling (mini-batch): required for large graphs (>100K nodes) — full-batch won't fit in memory
- Sampling strategy: document fan-out per layer (e.g., [25, 10] for 2-layer)
- Inductive vs. transductive: be explicit about which setting applies to your problem
- Negative sampling for link prediction: random negatives as baseline, hard negatives for better training
- Feature normalization: normalize numerical node features; use embeddings for high-cardinality categoricals

## Knowledge Graph Specific
- Triple format: (head, relation, tail) — validate for duplicate/contradictory triples
- Embedding models: TransE for simple relations, RotatE for complex patterns, ComplEx for symmetric
- Evaluation: Mean Reciprocal Rank (MRR), Hits@K (K=1,3,10) — report both filtered and raw
- Type constraints: enforce domain/range constraints on predicted triples
- Temporal KGs: use time-aware models; evaluate on future time slices only

## Evaluation
- Node classification: accuracy, macro-F1; split must respect graph structure (not random node split)
- Link prediction: MRR, Hits@K with proper negative sampling (not trivially easy negatives)
- Avoid data leakage: for link prediction, remove test edges from the training graph
- Evaluate by node degree bucket (low/medium/high) — models often fail on low-degree nodes
- Over-smoothing test: compare performance across different numbers of GNN layers

## Common Pitfalls
- Over-smoothing: too many GNN layers make all node representations converge — limits depth
- Information leakage in link prediction: test edges visible during training message passing
- Scalability: full-graph operations don't scale — always design for mini-batch from the start
- Ignoring graph structure changes: real-world graphs evolve — evaluate on updated graph snapshots
- Feature leakage: target label information encoded in neighbor features via message passing
