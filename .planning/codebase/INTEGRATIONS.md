# External Integrations

**Analysis Date:** 2026-01-23

## APIs & External Services

**Email & Notifications:**
- Resend - Email delivery service
  - SDK/Client: `resend` 6.7
  - Used in: `converge-www/functions/src/index.ts`
  - Purpose: Demo request notifications
  - Auth: `RESEND_API_KEY` (Firebase secret)
  - Sender: `Converge <onboarding@resend.dev>` (default domain until custom domain verified)
  - Status: Custom domain DKIM configuration pending

**LLM Providers:**
- Multiple providers supported via `converge-provider` abstraction
  - Anthropic (Claude) - `ANTHROPIC_API_KEY`
  - OpenAI (GPT-4, GPT-3.5) - `OPENAI_API_KEY`
  - Google Gemini - `GEMINI_API_KEY`
  - Perplexity AI (Web Search) - `PERPLEXITY_API_KEY`
  - OpenRouter (Aggregator) - `OPENROUTER_API_KEY`
  - Mistral AI - `MISTRAL_API_KEY`
  - Apertus (Switzerland/GDPR) - `APERTUS_API_KEY`
  - Qwen (Alibaba) - `QWEN_API_KEY`
  - Baidu ERNIE - `BAIDU_API_KEY`, `BAIDU_SECRET_KEY`
  - Zhipu GLM - `ZHIPU_API_KEY`
  - DeepSeek - `DEEPSEEK_API_KEY`
  - Kimi (Moonshot) - `KIMI_API_KEY`
  - MinMax AI - `MINMAX_API_KEY`
  - Grok (xAI) - `GROK_API_KEY`
  - HuggingFace (embeddings/reranker) - `HUGGINGFACE_API_KEY`
- Client: Custom HTTP implementations via `reqwest` 0.12
- Location: `converge-provider` crate and `converge-platform/.env.example`
- Model selection: Based on 5 orthogonal dimensions (jurisdiction, latency, cost, complexity, capabilities)

**Local LLM Inference:**
- Ollama - Local model serving
  - Config: `OLLAMA_URL=http://localhost:11434`
  - Models: Qwen 2.5 (7B), Llama 3.2 (3B), etc.
  - Integration: Supported via `converge-llm` Burn framework

## Data Storage

**Databases:**
- Google Firestore (Cloud Firestore)
  - Connection: Firebase Project ID `converge-369ad`
  - Client: `firebase-admin/firestore` 12.0
  - Collections: `demo-requests` (storing name, email, createdAt, status, source)
  - Rules file: `firestore.rules` (configured in `firebase.json`)
  - Indexes: `firestore.indexes.json` (configured in `firebase.json`)
  - Authentication: Service account via Firebase Admin SDK

**Vector Stores:**
- LanceDB 0.21 - Embedded vector storage (optional feature in `converge-provider`)
  - Used for: Semantic search and embeddings
  - Features: `lancedb` (optional)
  - Alternative: Qdrant (deferred), Neo4j graph store (deferred)
- Arrow - Columnar data format (0.55)

**File Storage:**
- Local filesystem - Content markdown files with YAML front-matter
- Firebase Hosting - Static asset distribution via CDN

## Authentication & Identity

**Auth Provider:**
- Firebase Authentication (configured but details in `firebase.json`)
- CORS origins for web: `https://converge.zone`, `https://www.converge.zone`, `https://converge-369ad.web.app`

**Secrets Management:**
- Firebase Cloud Functions secrets manager
  - `RESEND_API_KEY` - Email service API key
  - LLM provider keys (environment-based)
- Local development: `.env` files (gitignored)

## Monitoring & Observability

**Error Tracking:**
- Sentry 0.34 - Error and performance monitoring (optional feature in `converge-runtime`)
  - Features: backtrace, contexts, panic, tracing, reqwest, rustls integration
  - Configuration: Feature flag `sentry` in `converge-runtime`

**Metrics & Monitoring:**
- Prometheus - Metrics export (optional feature in `converge-runtime`)
  - Client: `metrics-exporter-prometheus` 0.13
  - Configuration: Feature flag `metrics` in `converge-runtime`

**Distributed Tracing:**
- OpenTelemetry 0.21 - Distributed tracing infrastructure (optional)
  - OTLP protocol for trace collection
  - Tonic integration for gRPC
  - Configuration: Feature flag `telemetry` in `converge-runtime`

**Logging:**
- Tracing subscriber framework with JSON and env-filter output
- Structured logging across all Rust services
- Browser console logging in web frontend

## CI/CD & Deployment

**Hosting:**
- Firebase Hosting - Web frontend static assets
  - Public directory: `dist/` (Vite build output)
  - Rewrite rule: SPA fallback to `/index.html`
  - Cache headers configured for assets and HTML
  - Security headers: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy

**Cloud Functions:**
- Google Cloud Functions (Firebase Functions)
  - Runtime: Node.js 20
  - Codebase: `api` (configured in `firebase.json`)
  - Region: `us-central1`
  - Pre-deploy: `bun run build` (TypeScript compilation)
  - Functions: `demoRequest` - Handles demo request submissions

**Container Runtime:**
- Docker support for services
  - Dockerfiles: `converge-runtime/Dockerfile`, `converge-ledger/Dockerfile`
  - Purpose: Container-based deployment for backend services

## Environment Configuration

**Required env vars:**

*Web Frontend (`converge-www`):**
- `VITE_API_URL` - Backend API endpoint (default: `http://localhost:8080` for dev)

*Platform (`converge-platform`)* (integration test keys):
- `ANTHROPIC_API_KEY` - Anthropic Claude API
- `OPENAI_API_KEY` - OpenAI API
- `GEMINI_API_KEY` - Google Gemini API
- `PERPLEXITY_API_KEY` - Perplexity web search
- `OPENROUTER_API_KEY` - OpenRouter aggregator
- `MISTRAL_API_KEY` - Mistral AI
- `APERTUS_API_KEY` - Apertus (GDPR-compliant)
- Chinese providers: `QWEN_API_KEY`, `BAIDU_API_KEY`, `BAIDU_SECRET_KEY`, `ZHIPU_API_KEY`, `DEEPSEEK_API_KEY`, `KIMI_API_KEY`
- Other: `MINMAX_API_KEY`, `GROK_API_KEY`, `HUGGINGFACE_API_KEY`
- Local: `OLLAMA_URL`

*Firebase Functions (`converge-www/functions`):*
- `RESEND_API_KEY` - Email service API key (Firebase secret)

**Secrets location:**
- Firebase Cloud Functions Secrets Manager - Production
- `.env` files (local, gitignored) - Development
- `.env.example` and `.env.development` - Templates for setup

**Optional custom endpoints:**
- `OPENROUTER_BASE_URL` - Custom OpenRouter endpoint
- `ANTHROPIC_BASE_URL` - Anthropic proxy/custom endpoint
- `OPENAI_BASE_URL` - OpenAI proxy/custom endpoint

## Webhooks & Callbacks

**Incoming:**
- `POST /api/v1/demo-request` - Firebase Cloud Function endpoint (`converge-www/functions`)
  - Accepts: `{ name: string, email: string }`
  - Stores in Firestore `demo-requests` collection
  - Sends notification via Resend
  - CORS protected: converge.zone domains only
  - Rate limiting: 5 requests per IP per hour

**Outgoing:**
- Resend email callbacks (optional) - Webhook for email delivery events (not yet configured)
- OpenTelemetry OTLP exporter - Traces sent to OTLP collector (when telemetry feature enabled)

## Data Sovereignty & Compliance

**Provider jurisdiction classification:**

EU/GDPR-Compliant:
- Mistral AI (France)
- Apertus (Switzerland)

US-Based:
- Anthropic, OpenAI, Google, Perplexity, xAI

China (data residency):
- Qwen (Alibaba), Baidu ERNIE, Zhipu GLM, DeepSeek, Kimi

Local/On-Premises (full control):
- Ollama with open models (Qwen, Llama, Mistral)

**Selection Criteria Implementation:**
- Jurisdiction constraints (unrestricted, trusted GDPR countries, same region, same country)
- Latency class (realtime <100ms, interactive <2s, background <30s, batch minutes)
- Cost tier (minimal, standard, premium)
- Task complexity (extraction, classification, reasoning, generation)
- Capabilities (tool_use, vision, structured_output, code, multilingual, web_search)

---

*Integration audit: 2026-01-23*
