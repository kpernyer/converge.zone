# converge-provider

**LLM Backend Implementations**

## Purpose

converge-provider implements the `ChatProvider` trait for external LLM services: Anthropic (Claude), OpenAI (GPT-4), and others. It handles API authentication, request formatting, response parsing, and error handling for each backend.

## Why It Matters

Models generate proposals; Converge governs promotion into commitment. But proposals still need to come from somewhere. converge-provider is the integration layer that connects the governance engine to foundation models without coupling the engine to any specific vendor.

Key design principles:

- **Provider Abstraction**: All backends implement the same `ChatProvider` trait
- **No Vendor Lock-in**: Switch providers without changing business logic
- **Structured I/O**: Typed `LlmRequest` and `LlmResponse`, not raw strings
- **Error Handling**: Provider failures are typed and recoverable

## Place in the Platform

converge-provider sits between the reasoning kernel and external services:

```
External APIs (Anthropic, OpenAI, etc.)
    ↑
converge-provider  ←── Backend implementations
    ↑
converge-llm (reasoning kernel)
    ↑
converge-application (user-facing)
```

The provider layer is intentionally thin. It does not contain reasoning logic—that belongs in converge-llm. It only handles the mechanics of API communication.

## Key Types

| Type | Role |
|------|------|
| `ChatProvider` | Trait for LLM backends |
| `AnthropicProvider` | Claude implementation |
| `OpenAiProvider` | GPT-4 implementation |
| `LlmRequest` | Structured prompt request |
| `LlmResponse` | Typed response with metadata |
| `LlmError` | Provider-specific error types |

## Governance Alignment

Provider abstraction supports a key governance property: **mechanism independence**. The choice of which model generates a proposal is a configuration decision, not a structural dependency. This means:

- Audit trails don't break when you switch models
- Flow definitions don't change when providers update APIs
- The governance layer (gates, invariants) remains stable

Models are interchangeable proposal generators. The governance rules are not.
