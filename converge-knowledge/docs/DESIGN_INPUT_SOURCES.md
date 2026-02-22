# Multi-Source Knowledge Architecture

## Overview

This document outlines the architecture for handling multiple input sources and distinguishing between different types of knowledge in the converge-knowledge system.

## Input Sources

### 1. Apple Notes Integration
```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Apple Notes   │───▶│  AppleScript │───▶│   Markdown/     │
│   (Notes.app)   │    │   Exporter   │    │   JSON Ingest   │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

**Implementation:**
- macOS AppleScript/JXA to extract notes
- Convert rich text to markdown
- Preserve folder hierarchy as categories
- Extract attachments (images, PDFs)

### 2. Photos with Text (OCR)
```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│     Photos      │───▶│   OCR Engine │───▶│   Text + Image  │
│   (PNG/JPEG)    │    │   (Tesseract │    │   Embeddings    │
└─────────────────┘    │   /Vision)   │    └─────────────────┘
                       └──────────────┘
```

**Implementation:**
- Apple Vision framework for OCR (macOS native)
- Tesseract as fallback
- Store both OCR text and image embedding
- Multi-modal search capability

### 3. Screenshots with Text
```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Screenshots   │───▶│  Screen Text │───▶│  Context-Aware  │
│   (Screen Cap)  │    │   Extraction │    │   Embedding     │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

**Implementation:**
- Detect UI elements vs content
- Extract structured information (menus, buttons, text blocks)
- Associate with app context (window title, URL)
- Higher weight for text content, lower for UI chrome

### 4. PDF Documents
```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   PDF Files     │───▶│  PDF Parser  │───▶│  Chunked Text   │
│   (Documents)   │    │   (pdf-rs)   │    │  + Metadata     │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

**Implementation:**
- Extract text with layout preservation
- Chunk by sections/pages
- Extract metadata (author, date, title)
- Handle tables and images separately

### 5. Markdown Documents
```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Markdown      │───▶│   MD Parser  │───▶│  Structured     │
│   Files (.md)   │    │  (pulldown)  │    │  Content        │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

**Implementation:**
- Parse markdown structure (headers, lists, code blocks)
- Preserve hierarchy for chunking
- Extract front-matter metadata
- Code blocks get separate embeddings

### 6. Video Content
```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Video Files   │───▶│  Transcript  │───▶│  Timestamped    │
│   (MP4/MOV)     │    │   Extractor  │    │  Knowledge      │
└─────────────────┘    └──────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │  Key Frames  │
                       │   (Visual)   │
                       └──────────────┘
```

**Implementation:**
- Whisper for audio transcription
- Key frame extraction for visual context
- Segment by topic/speaker changes
- Link timestamps to source video

---

## Knowledge Types

### Type 1: Case Knowledge (Foreground)

**Definition:** Direct, actionable knowledge relevant to the current task or case being worked on.

**Characteristics:**
- High relevance score
- Recently accessed or created
- Explicitly linked to current context
- Higher search priority

**Examples:**
- Project documentation
- Meeting notes for active projects
- Code snippets being used
- Reference materials for current work

**Data Model:**
```rust
pub struct CaseKnowledge {
    pub entry: KnowledgeEntry,
    pub case_context: String,      // Project/case identifier
    pub relevance_decay: f32,      // Time-based decay factor
    pub explicit_links: Vec<Uuid>, // Manually linked entries
    pub access_pattern: AccessPattern,
}

pub enum AccessPattern {
    ActiveUse,      // Currently being referenced
    RecentHistory,  // Used in last session
    Archived,       // Completed case knowledge
}
```

### Type 2: Background Knowledge (Indirect)

**Definition:** Contextual knowledge that informs understanding but isn't directly actionable for the current task.

**Characteristics:**
- Lower base relevance
- Provides context/understanding
- General reference material
- Supports case knowledge

**Examples:**
- General domain knowledge
- Best practices documentation
- Historical decisions and rationale
- Industry standards

**Data Model:**
```rust
pub struct BackgroundKnowledge {
    pub entry: KnowledgeEntry,
    pub domain: String,           // Knowledge domain
    pub permanence: Permanence,   // How stable is this knowledge
    pub supports: Vec<Uuid>,      // Case knowledge this supports
}

pub enum Permanence {
    Evergreen,   // Always valid (math, physics)
    Versioned,   // Valid for specific version
    Temporal,    // Valid for time period
    Deprecated,  // Outdated but kept for history
}
```

---

## Unified Search Strategy

### Query Processing Pipeline
```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│   Query     │──▶│  Intent     │──▶│  Knowledge  │──▶│   Merged    │
│   Input     │   │  Detection  │   │   Routing   │   │   Results   │
└─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘
                        │                  │
                        ▼                  ▼
                  ┌──────────┐     ┌──────────────┐
                  │  Case or │     │ Case Search  │
                  │Background│     │      +       │
                  │ Emphasis │     │ Background   │
                  └──────────┘     │    Search    │
                                   └──────────────┘
```

### Ranking Formula
```
final_score = (
    base_similarity * source_weight +
    case_relevance * context_boost +
    background_relevance * support_factor +
    recency_score * decay_factor +
    learned_relevance
)

where:
  source_weight = f(input_source_type)
  context_boost = 2.0 if case_match else 1.0
  support_factor = 0.5 for background knowledge
  decay_factor = exp(-days_since_access / half_life)
```

---

## Implementation Phases

### Phase 1: Core Source Support
- [ ] Markdown file ingestion
- [ ] PDF text extraction
- [ ] Basic text/category differentiation

### Phase 2: Apple Ecosystem
- [ ] Apple Notes export
- [ ] Screenshots OCR
- [ ] Photos text extraction

### Phase 3: Rich Media
- [ ] Video transcription
- [ ] Audio processing
- [ ] Multi-modal embeddings

### Phase 4: Knowledge Classification
- [ ] Case vs background detection
- [ ] Automatic relationship discovery
- [ ] Context-aware search ranking

---

## Source Configuration

```rust
pub struct SourceConfig {
    pub sources: Vec<InputSource>,
    pub sync_schedule: SyncSchedule,
    pub knowledge_routing: KnowledgeRouting,
}

pub enum InputSource {
    AppleNotes { folders: Vec<String> },
    FileSystem {
        paths: Vec<PathBuf>,
        patterns: Vec<String>,  // glob patterns
        recursive: bool,
    },
    Screenshots {
        path: PathBuf,
        ocr_engine: OcrEngine,
    },
    Video {
        paths: Vec<PathBuf>,
        transcription_model: String,
    },
}

pub struct KnowledgeRouting {
    /// Rules for classifying as case vs background
    pub rules: Vec<RoutingRule>,

    /// Default classification if no rules match
    pub default: KnowledgeType,
}

pub struct RoutingRule {
    pub condition: RoutingCondition,
    pub knowledge_type: KnowledgeType,
}

pub enum RoutingCondition {
    SourcePath(PathPattern),
    Category(String),
    Tag(String),
    ContentMatch(String),  // regex
    Metadata(String, String),
}
```

---

## API Extensions

### New gRPC Methods
```protobuf
service KnowledgeService {
    // Existing methods...

    // Source management
    rpc AddSource(AddSourceRequest) returns (AddSourceResponse);
    rpc SyncSource(SyncSourceRequest) returns (stream SyncProgress);
    rpc ListSources(ListSourcesRequest) returns (ListSourcesResponse);

    // Knowledge type queries
    rpc SearchCase(CaseSearchRequest) returns (SearchResponse);
    rpc SearchBackground(BackgroundSearchRequest) returns (SearchResponse);
    rpc GetSupportingKnowledge(GetSupportingRequest) returns (GetSupportingResponse);

    // Context management
    rpc SetActiveCase(SetActiveCaseRequest) returns (SetActiveCaseResponse);
    rpc LinkToCase(LinkToCaseRequest) returns (LinkToCaseResponse);
}
```

### MCP Tool Extensions
```json
{
    "tools": [
        {
            "name": "knowledge_search_case",
            "description": "Search case-specific knowledge with context awareness"
        },
        {
            "name": "knowledge_search_background",
            "description": "Search general background/reference knowledge"
        },
        {
            "name": "knowledge_set_context",
            "description": "Set the current case/project context for searches"
        },
        {
            "name": "knowledge_ingest_file",
            "description": "Ingest a file from supported source types"
        }
    ]
}
```
