# converge-analytics

**Data Analysis Engine**

## Purpose

converge-analytics provides Polars-based data analysis capabilities for Converge flows. It handles the quantitative side of decision-making: computing metrics, detecting patterns, evaluating feature importance, and preparing structured data for reasoning.

## Why It Matters

Business decisions require data, not just opinions. converge-analytics bridges the gap between raw data and governed reasoning:

- **Metrics Computation**: MAE, success ratios, confidence intervals
- **Feature Analysis**: Importance ranking, correlation detection
- **Data Quality**: Null detection, outlier flagging, drift monitoring
- **Aggregation**: Group-by operations, time series analysis

The output isn't a dashboard; it's structured facts that flow into the Context for agents to reason about.

## Place in the Platform

converge-analytics sits alongside the reasoning kernel:

```
Raw Data (CSV, Parquet, API responses)
    ↓
converge-analytics  ←── Polars pipelines
    ↓
StateInjection (structured metrics)
    ↓
converge-llm (reasoning with data)
    ↓
converge-domain (business decisions)
```

Analytics produces **State Injection** data for the reasoning kernel—not narrative summaries, but typed scalars, lists, and flags that agents can interpret.

## Key Capabilities

| Capability | Output |
|------------|--------|
| Evaluation metrics | `mae`, `success_ratio`, `confidence` |
| Feature importance | Ranked list of (feature, importance) |
| Data quality flags | `has_nulls`, `has_outliers`, `drift_detected` |
| Aggregations | Group statistics, time series |

## Integration with Reasoning

```rust
// Analytics produces metrics
let metrics = polars_pipeline.compute_metrics(&data)?;

// Metrics become structured state
let state = StateInjection::new()
    .with_scalar("mae", metrics.mae)
    .with_scalar("success_ratio", metrics.success_ratio)
    .with_list("top_features", metrics.top_features);

// State flows into reasoning
let stack = PromptStackBuilder::new()
    .state(state)
    .intent(UserIntent::new("interpret_metrics"))
    .build();
```

## Governance Alignment

Analytics under Converge is **evidence, not conclusion**. The data analysis layer produces:

- Typed metrics with explicit provenance
- Quality flags that trigger gates (e.g., "drift detected" → manual review)
- Structured inputs for reasoning, not narrative summaries

This supports the Evidence Gate: decisions must cite their data, and data quality issues surface before commitment.
