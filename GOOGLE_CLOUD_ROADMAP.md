# Converge.zone: Google Cloud Production Roadmap

This roadmap outlines the transition from local development and self-managed prototypes to a production-grade, highly available environment on Google Cloud, leveraging the latest features in gcloud SDK 558.0.0.

## Phase 1: Foundation & Managed Core
**Goal:** Replace manual infrastructure with managed services for compute and storage.

- [ ] **AlloyDB Migration:** Replace the SurrealDB "Experience Store" with **AlloyDB for PostgreSQL 18**.
    - Utilize `pgvector` for the core "Recall" (RAG) capabilities.
    - Implement append-only logic for the ledger using PostgreSQL optimized storage.
- [ ] **Cloud Run Deployment:** Containerize and deploy `converge-application` and `converge-www`.
    - Use **Direct VPC Egress** (GA in 558.0.0) for low-latency, secure connection to AlloyDB.
    - Configure scale-to-zero for non-critical services to optimize costs.
- [ ] **Data API Integration:** Leverage the **Cloud SQL Data API** (GA) for serverless database access, reducing connection pooling overhead in Rust.

## Phase 2: AI Scale & Enterprise Security
**Goal:** Enhance AI capabilities and secure the agentic workspace.

- [ ] **Vertex AI Integration:** Implement a `VertexAIBackend` in `converge-core/src/backend.rs`.
    - Use Gemini 2.0 for high-context "Storytelling" and reasoning tasks.
    - Deploy open-source models from **Model Garden** to replace self-hosted instances in `converge-llm`.
- [ ] **Vector Search Offloading:** Transition from local vector indexing to **Vertex AI Vector Search**.
    - Utilize the new **dense ScaNN search** parameters for sub-millisecond similarity lookups in "Recall".
- [ ] **Identity & Access:** 
    - Enable **Identity-Aware Proxy (IAP)** for all internal administrative UIs.
    - Implement **Workload Identity Federation** to eliminate static service account keys in the codebase.
    - Use **Cloud KMS** to manage encryption keys for tenant-specific "Context" data.

## Phase 3: Advanced Governance & Analytics
**Goal:** Implement the "Truth" and "Governance" layers at scale.

- [ ] **BigQuery Ledger Stream:** Stream all "Experience Event Envelopes" from the ledger into **BigQuery**.
    - Use BigQuery as the source of truth for long-term audit trails and compliance.
- [ ] **Real-time Governance:** 
    - Deploy **Dataflow** pipelines to process the event stream for "Authority Leaks" or "Agent Drift".
    - Implement **BigQuery Continuous Queries** to trigger governance alerts in real-time.
- [ ] **Visualization & Storytelling:**
    - Use **Looker** to visualize convergence quality, agent performance, and cost-per-outcome metrics.

---

## Technical Stack Mapping

| Converge Component | Local Assumption | Google Cloud Managed Service |
| :--- | :--- | :--- |
| **Compute** | Docker / Nix Shell | **Cloud Run** (Services) / **GKE** (Runtimes) |
| **Ledger DB** | SurrealDB | **AlloyDB for PostgreSQL 18** |
| **Vector Index** | Local Vector DB | **Vertex AI Vector Search** |
| **LLM Inference** | `converge-llm` | **Vertex AI Model Garden** |
| **Audit/Analytics** | Placeholder | **BigQuery + Looker** |
| **Secrets/Auth** | `.env` / Custom | **IAP + Cloud KMS + Secret Manager** |
| **Networking** | Localhost | **VPC + Service Directory** |
