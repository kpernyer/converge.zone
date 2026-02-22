# Converge Knowledge Architecture

## System Overview

Converge Knowledge is a self-learning knowledge base designed for AI agents. It combines vector search with learning mechanisms that improve over time.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Deployment                                      │
│                                                                              │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                   │
│   │   Client    │     │   Client    │     │   Client    │                   │
│   │  (Claude)   │     │   (Agent)   │     │   (CLI)     │                   │
│   └──────┬──────┘     └──────┬──────┘     └──────┬──────┘                   │
│          │                   │                   │                           │
│          │ MCP               │ gRPC              │ gRPC                      │
│          ▼                   ▼                   ▼                           │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                    Load Balancer / Gateway                       │       │
│   └────────────────────────────┬────────────────────────────────────┘       │
│                                │                                             │
│          ┌─────────────────────┼─────────────────────┐                      │
│          ▼                     ▼                     ▼                      │
│   ┌─────────────┐       ┌─────────────┐       ┌─────────────┐              │
│   │  Instance 1 │       │  Instance 2 │       │  Instance N │              │
│   │   (gRPC)    │       │   (gRPC)    │       │   (gRPC)    │              │
│   └──────┬──────┘       └──────┬──────┘       └──────┬──────┘              │
│          │                     │                     │                      │
│          └─────────────────────┼─────────────────────┘                      │
│                                │                                             │
│                                ▼                                             │
│                    ┌───────────────────────┐                                │
│                    │    Shared Storage     │                                │
│                    │  (Bincode / S3 / DB)  │                                │
│                    └───────────────────────┘                                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Scaling Strategy

### Horizontal Scaling

The system scales horizontally with the following considerations:

#### Read Path (Search)
```
Query → Any Instance → Local Vector Index → Return Results
                             │
                             └── Index replicated to all instances
```

- **Vector index is read-heavy** - Each instance holds a full replica
- **Search is CPU-bound** - Add instances for query throughput
- **Embedding is GPU/API-bound** - Can be offloaded to embedding service

#### Write Path (Add/Update)
```
Write → Leader Instance → Commit to Storage → Broadcast to Followers
              │
              └── Writes go through single leader for consistency
```

- **Single-writer model** for consistency (or eventual consistency with CRDTs)
- **Batch writes** reduce replication overhead
- **Write-behind caching** for high-throughput ingestion

### Vertical Scaling

| Resource | Bottleneck | Solution |
|----------|------------|----------|
| Memory | Vector index size | Shard by namespace/tenant |
| CPU | Search parallelism | More cores, batch queries |
| Disk I/O | Persistence | SSD, async writes |
| Network | Embedding API calls | Local model, caching |

### Scaling Dimensions

```
                    ┌─────────────────────────────────────────┐
                    │            Scaling Matrix               │
                    ├─────────────────────────────────────────┤
                    │                                         │
   Throughput ▲     │    ┌───────────┐      ┌───────────┐    │
              │     │    │ More      │      │ Sharding  │    │
              │     │    │ Instances │ ───▶ │ by Tenant │    │
              │     │    └───────────┘      └───────────┘    │
              │     │          │                   │          │
              │     │          ▼                   ▼          │
              │     │    ┌───────────┐      ┌───────────┐    │
              │     │    │ Read      │      │ Federated │    │
              │     │    │ Replicas  │      │ Query     │    │
              │     │    └───────────┘      └───────────┘    │
              │     │                                         │
              └─────┼─────────────────────────────────────────▶
                    │              Index Size                 │
                    └─────────────────────────────────────────┘
```

---

## Discovery & Service Registration

### Service Discovery Pattern

```rust
// Configuration for service discovery
pub struct DiscoveryConfig {
    /// Discovery backend
    pub backend: DiscoveryBackend,

    /// Service name for registration
    pub service_name: String,

    /// Health check interval
    pub health_interval: Duration,

    /// Metadata tags
    pub tags: Vec<String>,
}

pub enum DiscoveryBackend {
    /// Static configuration (development)
    Static { endpoints: Vec<String> },

    /// DNS-based discovery
    Dns { domain: String, port: u16 },

    /// Consul service mesh
    Consul { address: String, datacenter: String },

    /// Kubernetes service discovery
    Kubernetes { namespace: String, service: String },

    /// etcd-based discovery
    Etcd { endpoints: Vec<String>, prefix: String },
}
```

### Registration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Service Startup                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Load Configuration                                          │
│     ┌──────────────────────────────────────────────────────┐    │
│     │ config.toml / env vars / CLI args / discovery        │    │
│     └──────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  2. Initialize Components                                        │
│     ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│     │  Storage    │  │  Embedding  │  │  Learning   │          │
│     │  Backend    │  │   Engine    │  │   Engine    │          │
│     └─────────────┘  └─────────────┘  └─────────────┘          │
│                              │                                   │
│                              ▼                                   │
│  3. Register with Discovery                                      │
│     ┌──────────────────────────────────────────────────────┐    │
│     │  POST /v1/agent/service/register                      │    │
│     │  {                                                    │    │
│     │    "name": "converge-knowledge",                      │    │
│     │    "address": "10.0.1.5",                             │    │
│     │    "port": 50051,                                     │    │
│     │    "tags": ["grpc", "knowledge", "v1"],               │    │
│     │    "check": { "grpc": "10.0.1.5:50051", "interval": "10s" }│
│     │  }                                                    │    │
│     └──────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  4. Start Health Reporter                                        │
│     ┌──────────────────────────────────────────────────────┐    │
│     │  Every 10s: gRPC Health.Check() → Discovery          │    │
│     └──────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  5. Accept Connections                                           │
│     ┌──────────────────────────────────────────────────────┐    │
│     │  gRPC Server listening on :50051                     │    │
│     │  MCP Server listening on stdio / :3000               │    │
│     └──────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Runtime Configuration & Bootstrapping

### Configuration Hierarchy

Configuration is loaded in order (later overrides earlier):

```
1. Defaults (compiled in)
       │
       ▼
2. Config file (config.toml)
       │
       ▼
3. Environment variables (CONVERGE_*)
       │
       ▼
4. CLI arguments (--address, --storage)
       │
       ▼
5. Discovery service (dynamic)
       │
       ▼
   Final Configuration
```

### Configuration Schema

```toml
# config.toml

[server]
address = "0.0.0.0:50051"
max_connections = 1000
request_timeout = "30s"

[storage]
backend = "file"  # file, s3, postgres
path = "./data/knowledge.db"
# s3_bucket = "converge-knowledge"
# postgres_url = "postgres://..."

[embedding]
provider = "hash"  # hash, openai, local
dimensions = 384
# openai_api_key = "${OPENAI_API_KEY}"
# openai_model = "text-embedding-3-small"

[learning]
enabled = true
learning_rate = 0.01
ewc_lambda = 0.5
replay_buffer_size = 10000

[discovery]
enabled = false
backend = "consul"
# consul_address = "consul.service.consul:8500"

[telemetry]
enabled = true
otlp_endpoint = "http://jaeger:4317"
metrics_port = 9090
```

### Environment Variable Mapping

```bash
# All config values map to CONVERGE_* environment variables
CONVERGE_SERVER_ADDRESS=0.0.0.0:50051
CONVERGE_STORAGE_BACKEND=s3
CONVERGE_STORAGE_S3_BUCKET=my-bucket
CONVERGE_EMBEDDING_PROVIDER=openai
CONVERGE_EMBEDDING_OPENAI_API_KEY=sk-...
CONVERGE_LEARNING_ENABLED=true
CONVERGE_DISCOVERY_ENABLED=true
```

### Bootstrap Sequence

```rust
pub async fn bootstrap() -> Result<Application> {
    // 1. Parse CLI args
    let args = Args::parse();

    // 2. Load config file
    let mut config = Config::from_file(&args.config)?;

    // 3. Override with environment
    config.merge_env()?;

    // 4. Override with CLI args
    config.merge_args(&args)?;

    // 5. Connect to discovery (if enabled)
    if config.discovery.enabled {
        let discovery = DiscoveryClient::connect(&config.discovery).await?;

        // Get dynamic config from discovery
        let dynamic = discovery.get_config("converge-knowledge").await?;
        config.merge_dynamic(dynamic)?;
    }

    // 6. Validate final configuration
    config.validate()?;

    // 7. Initialize components
    let storage = StorageBackend::from_config(&config.storage).await?;
    let embedding = EmbeddingEngine::from_config(&config.embedding)?;
    let learning = LearningEngine::from_config(&config.learning)?;

    // 8. Build knowledge base
    let kb = KnowledgeBase::new(storage, embedding, learning).await?;

    // 9. Start servers
    let grpc = GrpcServer::new(kb.clone(), &config.server);
    let mcp = McpServer::new(kb.clone());

    // 10. Register with discovery
    if config.discovery.enabled {
        discovery.register(&config).await?;
    }

    // 11. Start health reporter
    let health = HealthReporter::new(kb.clone());

    Ok(Application { grpc, mcp, health, discovery })
}
```

---

## Data Flow

### Ingestion Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │───▶│  Ingester   │───▶│   Router    │───▶│  Knowledge  │
│  (MD/PDF)   │    │  (Chunk)    │    │ (Classify)  │    │    Base     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                  │                   │
                          │                  │                   │
                          ▼                  ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                   │  Metadata   │    │  Case vs    │    │  Vector     │
                   │  Extraction │    │  Background │    │  Embedding  │
                   └─────────────┘    └─────────────┘    └─────────────┘
```

### Query Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Query     │───▶│  Embedding  │───▶│   Vector    │───▶│  Learning   │
│   Input     │    │   Engine    │    │   Search    │    │   Rerank    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                │
                                                                ▼
                                                         ┌─────────────┐
                                                         │   Results   │
                                                         └─────────────┘
                                                                │
                                            ┌───────────────────┼───────────────────┐
                                            ▼                   ▼                   ▼
                                     ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                                     │   User      │    │  Session    │    │   Skill     │
                                     │  Feedback   │    │  Recording  │    │  Matching   │
                                     └─────────────┘    └─────────────┘    └─────────────┘
```

### Learning Feedback Loop

```
                    ┌─────────────────────────────────────┐
                    │          Learning Loop              │
                    │                                     │
                    │  ┌─────────────────────────────┐   │
                    │  │        Query + Results       │   │
                    │  └──────────────┬──────────────┘   │
                    │                 │                   │
                    │                 ▼                   │
                    │  ┌─────────────────────────────┐   │
                    │  │      User Feedback          │   │
                    │  │   (clicked, ignored, etc.)  │   │
                    │  └──────────────┬──────────────┘   │
                    │                 │                   │
                    │      ┌──────────┴──────────┐       │
                    │      ▼                     ▼       │
                    │  ┌─────────┐         ┌─────────┐   │
                    │  │Experience│         │Relevance│   │
                    │  │ Replay  │         │ Weights │   │
                    │  └────┬────┘         └────┬────┘   │
                    │       │                   │        │
                    │       └─────────┬─────────┘        │
                    │                 ▼                   │
                    │  ┌─────────────────────────────┐   │
                    │  │       GNN Layer Update       │   │
                    │  │     (with EWC protection)    │   │
                    │  └──────────────┬──────────────┘   │
                    │                 │                   │
                    │                 ▼                   │
                    │  ┌─────────────────────────────┐   │
                    │  │     Better Future Search     │   │
                    │  └─────────────────────────────┘   │
                    │                                     │
                    └─────────────────────────────────────┘
```

---

## Deployment Patterns

### Single Instance (Development)

```yaml
# docker-compose.yml
services:
  converge-knowledge:
    image: converge/knowledge:latest
    ports:
      - "50051:50051"  # gRPC
      - "3000:3000"    # MCP HTTP
    volumes:
      - ./data:/data
    environment:
      CONVERGE_STORAGE_PATH: /data/knowledge.db
```

### Multi-Instance (Production)

```yaml
# kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: converge-knowledge
spec:
  replicas: 3
  selector:
    matchLabels:
      app: converge-knowledge
  template:
    spec:
      containers:
        - name: knowledge
          image: converge/knowledge:latest
          ports:
            - containerPort: 50051
          env:
            - name: CONVERGE_STORAGE_BACKEND
              value: "s3"
            - name: CONVERGE_DISCOVERY_ENABLED
              value: "true"
            - name: CONVERGE_DISCOVERY_BACKEND
              value: "kubernetes"
          resources:
            requests:
              memory: "2Gi"
              cpu: "1000m"
            limits:
              memory: "8Gi"
              cpu: "4000m"
---
apiVersion: v1
kind: Service
metadata:
  name: converge-knowledge
spec:
  selector:
    app: converge-knowledge
  ports:
    - port: 50051
      targetPort: 50051
```

### Sharded (Large Scale)

```
┌─────────────────────────────────────────────────────────────────┐
│                        Query Router                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Route by: tenant_id % num_shards                        │    │
│  └─────────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
  │  Shard 0    │     │  Shard 1    │     │  Shard N    │
  │ tenant 0,3  │     │ tenant 1,4  │     │ tenant 2,5  │
  │  replicas   │     │  replicas   │     │  replicas   │
  └─────────────┘     └─────────────┘     └─────────────┘
```

---

## Security

### Authentication

```rust
pub enum AuthMethod {
    /// No authentication (development)
    None,

    /// API key in header
    ApiKey { header: String },

    /// JWT token validation
    Jwt { issuer: String, audience: String },

    /// mTLS client certificates
    MutualTls { ca_cert: PathBuf },
}
```

### Authorization

```rust
pub struct Permission {
    pub resource: Resource,
    pub action: Action,
}

pub enum Resource {
    Entry(Option<Uuid>),  // Specific entry or all
    Namespace(String),
    System,
}

pub enum Action {
    Read,
    Write,
    Delete,
    Admin,
}

// Check permission before operation
fn check_permission(user: &User, permission: &Permission) -> Result<()>;
```

---

## Observability

### Metrics (Prometheus)

```
# Query latency
converge_query_duration_seconds{method="search"}

# Entries count
converge_entries_total{namespace="default"}

# Learning updates
converge_learning_updates_total

# Embedding cache hits
converge_embedding_cache_hits_total
```

### Tracing (OpenTelemetry)

```
Span: search
├── Span: embed_query
│   └── Span: openai_api_call
├── Span: vector_search
│   └── Span: hnsw_search
├── Span: learning_rerank
│   └── Span: gnn_forward
└── Span: format_results
```

### Logging

```rust
tracing::info!(
    query = %query,
    results = results.len(),
    latency_ms = elapsed.as_millis(),
    "Search completed"
);
```

---

## Future Considerations

### Planned Features

1. **Distributed Consensus** - Raft for multi-writer consistency
2. **Incremental Index Updates** - Avoid full rebuilds
3. **Federated Search** - Query across multiple instances
4. **Streaming Ingestion** - Kafka/Pulsar integration
5. **Graph Queries** - Cypher-like syntax for causal memory

### Performance Targets

| Metric | Target |
|--------|--------|
| Search latency (p99) | < 50ms |
| Ingestion throughput | 1000 docs/sec |
| Index size | 1M vectors in 4GB RAM |
| Learning update | < 10ms per feedback |
