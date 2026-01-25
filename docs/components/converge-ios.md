# converge-ios

**iOS SDK**

## Purpose

converge-ios provides a native Swift SDK for integrating Converge into iOS applications. It handles communication with the Converge runtime, local state management, and iOS-specific patterns like async/await and Combine.

## Why It Matters

Business commitments happen on mobile devices:

- Sales reps approve quotes in the field
- Managers review and authorize from their phones
- Field workers submit data that feeds into decisions

converge-ios brings Converge governance to iOS:

- **Native Integration**: Swift types, async/await, Combine publishers
- **Offline Support**: Queue jobs when offline, sync when connected
- **Secure Storage**: Keychain for credentials, secure enclave for signing
- **Push Notifications**: Alert when approvals are needed

## Place in the Platform

converge-ios connects mobile apps to the runtime:

```
iOS Application
    ↓
converge-ios  ←── Swift SDK
    ↓
HTTPS
    ↓
converge-runtime (server)
```

The SDK provides a typed Swift interface that mirrors the Rust types, ensuring type safety from mobile to server.

## Key Components

| Component | Purpose |
|-----------|---------|
| `ConvergeClient` | Main API client |
| `Job` | Job submission and tracking |
| `Context` | Local context management |
| `Fact` | Typed fact models |
| `StreamSubscriber` | SSE streaming support |

## Example Usage

```swift
let client = ConvergeClient(baseURL: "https://api.converge.zone")

// Submit a job
let job = try await client.submitJob(
    template: "growth-strategy",
    seeds: [
        Fact(key: .seeds, id: "company", content: "Acme Corp")
    ]
)

// Stream results
for try await fact in client.streamJob(job.id) {
    print("New fact: \(fact.id)")
}
```

## Governance Alignment

The iOS SDK maintains governance properties:

- **Authority**: User identity flows through to audit trail
- **Offline Resilience**: Jobs queue locally, submit when connected
- **Secure Credentials**: Provider keys in Keychain, not in code
- **Audit Integration**: Mobile actions appear in converge-ledger

This ensures mobile users participate in the commitment system with full governance, not as a second-class interface.
