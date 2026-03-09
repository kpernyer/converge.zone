# MultiphysicsAI Agent for Converge Zone

## Vision

A physics-aware agent that proposes facts for convergence based on physical AI reasoning. When a quality manager observes drift in production, they describe observations in natural language and images. The MultiphysicsAI agent provides causal hypotheses grounded in physics — governed by Converge's commitment architecture.

What MultiphysicsAI brings is models that introduce an understanding of the physical world and physics into the decision-making process. A quality manager asks what is causing a quality drift appearing in production, describes observations in natural language and with images, and the system provides an extraordinarily capable problem-solving assistant — with full auditability and governance.

## Architecture Fit

The agent implements the standard `Agent` trait:

```rust
pub struct MultiphysicsAgent {
    provider: Arc<dyn LlmProvider>,
}

impl Agent for MultiphysicsAgent {
    fn name(&self) -> &'static str { "MultiphysicsAgent" }

    fn dependencies(&self) -> &[ContextKey] {
        &[ContextKey::Seeds, ContextKey::Signals]
    }

    fn accepts(&self, ctx: &Context) -> bool {
        // Run when physical observations exist but no root causes yet
        ctx.has(ContextKey::Signals) && !ctx.has(ContextKey::Custom("PhysicsHypotheses"))
    }

    fn execute(&self, ctx: &Context) -> AgentEffect {
        // 1. Gather observation facts (text, sensor readings, images)
        // 2. Build physics-aware prompt with domain constraints
        // 3. Call multimodal LLM with physics priming
        // 4. Parse response into causal hypotheses as facts
        AgentEffect::with_facts(facts)
    }
}
```

## Domain Pack: `quality-diagnosis`

### Agent Pipeline

```
Seeds (operator observations, sensor data, images, process params)
    ↓
MultiphysicsAgent → PhysicsHypotheses (causal models)
    ↓
SensorCorrelationAgent → Signals (statistical anomalies)
    ↓
RootCauseAgent → RootCauses (ranked explanations)
    ↓
CorrectionStrategyAgent → Strategies (actionable fixes)
    ↓
EvaluationAgent → Evaluations (scored strategies)
    ↓
[Invariants]
    ↓
Convergence → Commitment
```

### Invariants

| Invariant | Enforces |
|-----------|----------|
| `CausalChainRequiresEvidenceInvariant` | No unsupported causal claims |
| `PhysicsConsistencyInvariant` | Hypotheses must be physically plausible |
| `SafetyBoundaryInvariant` | Corrections must respect safety limits |

### Example Seeds

```json
[
  {
    "key": "Seeds",
    "id": "observation:quality-drift",
    "content": "Surface roughness on aluminum extrusions increasing 15% over past 72 hours. Die temperature stable. Billet preheat within spec."
  },
  {
    "key": "Seeds",
    "id": "observation:sensor-data",
    "content": "Ram speed: 12mm/s (nominal 12). Exit temp: 542°C (nominal 530°C). Pressure: 2450 psi (nominal 2400 psi)."
  },
  {
    "key": "Seeds",
    "id": "observation:operator-note",
    "content": "New billet supplier started 4 days ago. Alloy cert says 6063-T5, same as before."
  },
  {
    "key": "Seeds",
    "id": "context:process",
    "content": "Aluminum extrusion line 3, 7-inch press, running 24/7."
  }
]
```

### Expected Convergence Output

The agent pipeline should converge on facts like:

```json
[
  {
    "key": "PhysicsHypotheses",
    "id": "hypothesis:alloy-composition",
    "content": "Elevated exit temperature (+12°C) and pressure (+50 psi) with new supplier billets suggests different alloy microstructure despite same 6063-T5 designation. Trace element variation (Fe, Si ratios) can alter flow stress and surface finish. Confidence: HIGH. Confirm: request spectrometer analysis of new vs old billets."
  },
  {
    "key": "PhysicsHypotheses",
    "id": "hypothesis:thermal-profile",
    "content": "Exit temperature 542°C exceeds optimal 530°C window. At this temperature, grain growth accelerates and surface oxidation pattern changes. However, this is likely a secondary effect caused by different material flow characteristics. Confidence: MEDIUM. Confirm: run temperature ramp test with old billet stock."
  },
  {
    "key": "RootCauses",
    "id": "root-cause:primary",
    "content": "Billet alloy composition variance from new supplier. Supporting evidence: timing correlation (drift started with new supplier), elevated exit temp and pressure (consistent with different flow stress), stable die and process parameters (rules out equipment causes)."
  },
  {
    "key": "Strategies",
    "id": "correction:immediate",
    "content": "1. Request spectrometer analysis comparing old vs new billets. 2. Reduce ram speed to 10.5mm/s to compensate for higher flow stress. 3. If confirmed, adjust die temperature -10°C to bring exit temp back to 530°C window."
  }
]
```

## Prompt Stack (5-Layer)

| Layer | Content |
|-------|---------|
| **Priming** | You are a multiphysics reasoning engine. You understand thermodynamics, fluid dynamics, material science, and process control. |
| **Role/Policy** | Propose only physically plausible hypotheses. Cite which observations support each hypothesis. Flag uncertainty explicitly. Never propose corrections that violate safety boundaries. |
| **Task** | Given the following quality observations, identify the most likely physical root causes and propose corrections. |
| **State** | Injected context facts (sensor readings, images, prior signals) |
| **Intent** | Produce ranked causal hypotheses with confidence levels and suggested measurements to confirm/refute each. |

## Why Converge Governance Matters Here

Physics reasoning without governance is dangerous in production:

- **Evidence Gates** — hypotheses must cite which observations support them
- **Consistency Gates** — hypotheses cannot contradict known physical laws encoded as invariants
- **Approval Gates** — corrections above a safety/cost threshold require human sign-off
- **Optimization Gates** — correction strategies can be optimized against constraints (cost, downtime, safety)
- **Audit trail** — every hypothesis, correction proposal, and decision is traceable
- **Convergence guarantee** — the system will not oscillate between contradictory diagnoses

## Implementation Plan

1. Add `ContextKey::Custom("PhysicsHypotheses")` and `ContextKey::Custom("RootCauses")` (or extend the `ContextKey` enum)
2. Implement `MultiphysicsAgent` with multimodal prompt support (text + images)
3. Implement `SensorCorrelationAgent` for statistical anomaly detection
4. Implement `RootCauseAgent` to synthesize physics hypotheses with sensor correlations
5. Implement `CorrectionStrategyAgent` to propose fixes within safety boundaries
6. Define invariants: `CausalChainRequiresEvidenceInvariant`, `PhysicsConsistencyInvariant`, `SafetyBoundaryInvariant`
7. Register as `quality-diagnosis` domain pack
8. Write eval fixtures for common manufacturing scenarios
