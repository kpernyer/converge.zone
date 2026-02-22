# Converge Knowledge

A self-learning knowledge base built in pure Rust, inspired by [ruvector](https://github.com/ruvector/ruvector). The system gets smarter the more you use it through GNN-inspired learning, meta-learning, and agent memory patterns.

## When to Use This

| Use Case | Capability | Module |
|----------|------------|--------|
| **Building an AI agent with memory** | Store past actions, learn from mistakes | `AgenticDB` |
| **Semantic search over documents** | Vector similarity + learning | `KnowledgeBase` |
| **Ingesting markdown/PDF files** | Chunking, metadata extraction | `ingest` |
| **Claude Desktop integration** | Natural language knowledge access | `MCP Server` |
| **Microservice knowledge store** | High-performance RPC | `gRPC Server` |
| **Detecting recurring patterns** | Time-based activity analysis | `TimeCrystal` |
| **Quick adaptation to new tasks** | Few-shot learning | `MetaLearner` |
| **Preventing model forgetting** | EWC, experience replay | `OnlineLearner` |

---

## Capabilities

### 1. Core Knowledge Base

**When useful:** You need semantic search over text with learning from user feedback.

```rust
use converge_knowledge::{KnowledgeBase, KnowledgeEntry, SearchOptions};

let kb = KnowledgeBase::open("./knowledge.db").await?;

// Add knowledge
kb.add_entry(KnowledgeEntry::new("Rust Ownership", "...")).await?;

// Search (learns from usage)
let results = kb.search("memory safety", SearchOptions::new(5)).await?;

// Feedback improves future searches
kb.record_feedback(results[0].id(), true).await?;
```

---

### 2. AgenticDB - Agent Memory System

**When useful:** Building AI agents that need to remember, learn, and improve over time.

#### Reflexion Episodes (Self-Critique)
**When useful:** Agent should learn from its mistakes and not repeat them.

```rust
use converge_knowledge::{AgenticDB, ReflexionEpisode, Critique, CritiqueType};

let db = AgenticDB::new();

// Agent failed - record what went wrong
let episode = ReflexionEpisode::new(
    "code_generation",
    "Write a sorting function",
    "fn sort() { /* buggy */ }",
    false,  // failed
)
.with_critique(Critique::new(
    CritiqueType::LogicError,
    "Off-by-one error in loop bounds",
    "Use 0..len instead of 0..=len",
));

db.add_reflexion(episode).await;

// Later: check past failures before attempting similar task
let past_failures = db.query_similar_failures("sorting algorithm", 5).await;
```

#### Skill Library
**When useful:** Agent should consolidate successful patterns for reuse.

```rust
use converge_knowledge::{Skill, SkillPattern};

let skill = Skill::new(
    "error_handling",
    "Rust Result Pattern",
    vec![
        SkillPattern::new("define_error", "#[derive(Error)] enum AppError {...}"),
        SkillPattern::new("propagate", "let value = risky_op()?;"),
    ],
)
.with_preconditions(vec!["Function can fail".into()])
.with_postconditions(vec!["Errors are typed".into()]);

db.register_skill(skill).await;
```

#### Causal Memory
**When useful:** Agent should understand cause-effect relationships.

```rust
use converge_knowledge::{CausalNode, CausalEdge};

// Build knowledge: "Using unwrap() causes panics"
let unwrap_id = memory.add_node(CausalNode::new("Using unwrap()", "code_pattern"));
let panic_id = memory.add_node(CausalNode::new("Runtime panic", "error"));

memory.add_edge(CausalEdge::new(unwrap_id, panic_id, "causes", 0.8));

// Query: What causes panics?
let causes = memory.find_causes(panic_id);

// Trace causal chain
let chain = memory.trace_chain(unwrap_id, 5);
```

#### Learning Sessions (RL)
**When useful:** Training agent behavior with rewards.

```rust
use converge_knowledge::{LearningSession, SessionTurn, Reward};

let session_id = db.start_session("Fix bug in auth module").await;

db.record_turn(session_id, "read auth.rs", "Found issue", Reward::Neutral).await;
db.record_turn(session_id, "edit auth.rs", "Fixed null check", Reward::Positive(0.5)).await;
db.record_turn(session_id, "run tests", "All passing", Reward::Positive(1.0)).await;

// Get trajectory for training
let trajectory = session.to_trajectory();
let discounted_return = session.discounted_return(0.99);
```

---

### 3. Time Crystals - Temporal Patterns

**When useful:** Detecting periodic behavior patterns (daily coding hours, weekly deploys, etc.)

```rust
use converge_knowledge::{TimeCrystal, TemporalPeriod, TemporalMemory};

let mut memory = TemporalMemory::new();

// Track daily coding activity
memory.record("coding", TemporalPeriod::Daily, 1.0);

// Predict activity at current time
let expected = memory.predict("coding");

// Detect anomalies (unusual 3am activity)
let crystal = memory.get("coding").unwrap();
if crystal.is_anomalous(&now, observed_value, 0.3) {
    alert("Unusual activity detected");
}

// Find best time for an activity
let best_hour = crystal.best_time();  // Returns hour with highest activity
```

---

### 4. Online Learning - Continual Adaptation

**When useful:** Model should adapt to new data without forgetting previous knowledge.

#### EWC (Elastic Weight Consolidation)
```rust
use converge_knowledge::OnlineLearner;

let mut learner = OnlineLearner::new("preferences", 64)
    .with_learning_rate(0.01)
    .with_ewc_lambda(0.5);  // Forgetting prevention strength

// Train on Task A
for (features, target) in task_a_data {
    learner.update(&features, target);
}

// Consolidate - remember what was important for Task A
learner.consolidate();

// Train on Task B - EWC prevents forgetting Task A
for (features, target) in task_b_data {
    learner.update(&features, target);
}
```

#### Distribution Drift Detection
```rust
use converge_knowledge::DriftDetector;

let mut detector = DriftDetector::new(64).with_threshold(2.0);

// Monitor incoming features
if detector.update(&features) {
    println!("Distribution shift detected - consider retraining");
}

if detector.is_drifting() {
    trigger_adaptation();
}
```

#### Experience Replay
```rust
use converge_knowledge::ExperienceWindow;

let mut window = ExperienceWindow::new(1000);

// Store experiences
window.add(features, target, Some("task_a".into()));

// Sample for rehearsal (prevents forgetting)
let batch = window.sample(32);
for exp in batch {
    model.train(&exp.features, exp.target);
}
```

---

### 5. Meta-Learning - Learning to Learn

**When useful:** Agent faces many similar tasks and should learn to adapt quickly.

#### MAML/Reptile-Style Meta-Learning
```rust
use converge_knowledge::{MetaLearner, FewShotLearner, TaskFeatures};

let mut meta = MetaLearner::new("task_solver", 64)
    .with_meta_lr(0.1)
    .with_inner_lr(0.01);

// After completing each task, update meta-learner
meta.meta_update("task_1", &final_params, task_embedding);
meta.meta_update("task_2", &final_params, task_embedding);

// For a new task: get good initialization
let init_params = meta.initialize_for_task(Some(&task_embedding));
```

#### Few-Shot Learning
```rust
// Quick adaptation with few examples
let mut few_shot = FewShotLearner::from_meta(&meta, Some(&task_embedding))
    .with_adapt_steps(5);

// Add just a few examples
few_shot.add_example(vec![1.0, 2.0], 5.0);
few_shot.add_example(vec![2.0, 3.0], 8.0);

// Adapt and predict
few_shot.adapt();
let prediction = few_shot.predict(&[3.0, 4.0]);
```

#### Learning Strategy Selection
```rust
use converge_knowledge::{LearningStrategy, TaskFeatures};

// Register strategies that worked
let strategy = LearningStrategy::new("few_shot")
    .with_description("For small datasets")
    .with_hyperparam("lr", 0.1)
    .with_preferred_features(TaskFeatures::new().with_data_size(10));

meta.register_strategy(strategy);

// Select best strategy for new task
let task = TaskFeatures::new().with_data_size(15).with_noise(0.1);
let selected = db.select_strategy(&task).await;
```

---

### 6. Document Ingestion

**When useful:** Importing documents from files into the knowledge base.

#### Markdown Files
```rust
use converge_knowledge::ingest::{MarkdownIngester, MarkdownDocument};

let ingester = MarkdownIngester::new();

// Ingest single file (extracts front-matter, chunks by headers)
let doc = ingester.ingest_file("docs/guide.md").await?;

// Ingest directory recursively
let docs = ingester.ingest_directory("./docs", true).await?;

for chunk in &doc.chunks {
    kb.add_entry(KnowledgeEntry::new(&chunk.heading_hierarchy.join(" > "), &chunk.content)).await?;
}
```

#### PDF Files
```rust
use converge_knowledge::ingest::{PdfIngester, PdfDocument};

let ingester = PdfIngester::new();
let doc = ingester.ingest_file("paper.pdf")?;

println!("Title: {:?}", doc.title);
println!("Pages: {}", doc.page_count);

for chunk in &doc.chunks {
    println!("Page {}: {}", chunk.page_number, &chunk.content[..100]);
}
```

#### Knowledge Classification (Case vs Background)
```rust
use converge_knowledge::ingest::{KnowledgeRouter, RoutingRule, RoutingCondition, KnowledgeType};

let mut router = KnowledgeRouter::new();

// Project docs are "case knowledge" (high priority, context-specific)
router.add_rule(RoutingRule {
    condition: RoutingCondition::SourcePath("projects/*".into()),
    knowledge_type: KnowledgeTypeHint::Case,
});

// Reference docs are "background knowledge" (supporting context)
router.add_rule(RoutingRule {
    condition: RoutingCondition::Category("reference".into()),
    knowledge_type: KnowledgeTypeHint::Background,
});

// Classify incoming content
let knowledge_type = router.classify(&path, &content, &metadata);
```

---

### 7. Interfaces

#### gRPC Server
**When useful:** Microservice integration, high-performance RPC.

```bash
# Start server
just server

# Or with cargo
cargo run --bin converge-knowledge-server -- --address 0.0.0.0:50051
```

```protobuf
service KnowledgeService {
    rpc AddEntry(AddEntryRequest) returns (AddEntryResponse);
    rpc Search(SearchRequest) returns (SearchResponse);
    rpc SearchStream(SearchRequest) returns (stream SearchResult);
    rpc RecordFeedback(FeedbackRequest) returns (FeedbackResponse);
    // ... 12 methods total
}
```

#### MCP Server (Claude Desktop)
**When useful:** Using the knowledge base directly from Claude Desktop.

```bash
just mcp  # Start MCP server
```

Tools available in Claude:
- `knowledge_search` - Semantic search
- `knowledge_add` - Add entries
- `knowledge_get` - Get by ID
- `knowledge_feedback` - Improve search
- `knowledge_stats` - Statistics

#### CLI
```bash
# Add knowledge
just add "Topic" "Content here..."

# Search
just search "query terms"

# Import files
just import ./docs/

# Stats
just stats
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                       Converge Knowledge                             │
├─────────────────────────────────────────────────────────────────────┤
│  Interfaces                                                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────────────────┐ │
│  │   CLI   │  │  gRPC   │  │   MCP   │  │     Library API         │ │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────────────┬────────────┘ │
│       └────────────┴────────────┴────────────────────┘              │
│                              │                                       │
├──────────────────────────────┼───────────────────────────────────────┤
│  Core                        │                                       │
│  ┌───────────────────────────┴────────────────────────────────────┐ │
│  │                      KnowledgeBase                              │ │
│  │  ┌─────────────┐  ┌───────────────┐  ┌──────────────────────┐  │ │
│  │  │  Embedding  │  │   Learning    │  │      Storage         │  │ │
│  │  │   Engine    │  │    Engine     │  │      Backend         │  │ │
│  │  │ Hash/OpenAI │  │  GNN + EWC    │  │      Bincode         │  │ │
│  │  └─────────────┘  └───────────────┘  └──────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
├───────────────────────────────────────────────────────────────────────┤
│  AgenticDB (Agent Memory)                                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │
│  │  Reflexion   │ │    Skill     │ │   Causal     │ │   Learning   │ │
│  │  Episodes    │ │   Library    │ │   Memory     │ │   Sessions   │ │
│  │ Self-critique│ │   Patterns   │ │  Hypergraph  │ │  RL Rewards  │ │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ │
│                                                                       │
├───────────────────────────────────────────────────────────────────────┤
│  Advanced Learning                                                    │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │
│  │    Time      │ │   Online     │ │    Meta      │ │   Drift      │ │
│  │  Crystals    │ │   Learner    │ │   Learner    │ │  Detector    │ │
│  │  Temporal    │ │   EWC+Replay │ │  MAML-style  │ │  Shift Alert │ │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ │
│                                                                       │
├───────────────────────────────────────────────────────────────────────┤
│  Ingestion                                                           │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                  │
│  │   Markdown   │ │     PDF      │ │   Knowledge  │                  │
│  │   Ingester   │ │   Ingester   │ │    Router    │                  │
│  │  Chunks/YAML │ │  Pages/Meta  │ │ Case vs Bkgd │                  │
│  └──────────────┘ └──────────────┘ └──────────────┘                  │
└───────────────────────────────────────────────────────────────────────┘
```

---

## Quick Start

```bash
# Build
cargo build --release

# Run tests
cargo test

# Start gRPC server
cargo run --bin converge-knowledge-server

# Start MCP server (for Claude Desktop)
cargo run --bin converge-knowledge-mcp

# Use CLI
cargo run -- search "your query"
```

---

## Dependencies

- **Rust 2024 Edition** (1.85+)
- **tokio** - Async runtime
- **tonic** - gRPC
- **serde** - Serialization
- **pulldown-cmark** - Markdown parsing
- **pdf-extract** - PDF text extraction
- **OpenAI API** (optional) - Production embeddings

---

## License

MIT
