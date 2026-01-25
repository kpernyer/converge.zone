# converge-android

**Android SDK**

## Purpose

converge-android provides a native Kotlin SDK for integrating Converge into Android applications. It handles communication with the Converge runtime, local state management, and Android-specific patterns like coroutines and Flow.

## Why It Matters

Android dominates enterprise mobile:

- Field sales teams run on Android tablets
- Warehouse workers use Android scanners
- Delivery drivers submit from Android phones

converge-android brings Converge governance to Android:

- **Native Integration**: Kotlin types, coroutines, Flow streams
- **Offline Support**: Room database for job queuing
- **Secure Storage**: EncryptedSharedPreferences, Android Keystore
- **WorkManager**: Background sync for pending jobs

## Place in the Platform

converge-android connects Android apps to the runtime:

```
Android Application
    ↓
converge-android  ←── Kotlin SDK
    ↓
HTTPS
    ↓
converge-runtime (server)
```

The SDK provides a typed Kotlin interface that mirrors the Rust types, with Android-idiomatic patterns.

## Key Components

| Component | Purpose |
|-----------|---------|
| `ConvergeClient` | Main API client |
| `Job` | Job submission and tracking |
| `Context` | Local context management |
| `Fact` | Typed fact models |
| `JobRepository` | Room-backed persistence |

## Example Usage

```kotlin
val client = ConvergeClient("https://api.converge.zone")

// Submit a job
val job = client.submitJob(
    template = "growth-strategy",
    seeds = listOf(
        Fact(key = ContextKey.SEEDS, id = "company", content = "Acme Corp")
    )
)

// Stream results
client.streamJob(job.id).collect { fact ->
    println("New fact: ${fact.id}")
}
```

## Governance Alignment

The Android SDK maintains governance properties:

- **Authority**: User identity flows through to audit trail
- **Offline Resilience**: Room database queues jobs locally
- **Secure Credentials**: Android Keystore for provider keys
- **Background Sync**: WorkManager ensures jobs complete

This ensures Android users participate in the commitment system with full governance, matching the iOS experience.
