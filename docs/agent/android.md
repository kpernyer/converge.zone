# Android Agent Guide

Baseline commands (adjust to repo wrappers):

```bash
./gradlew assembleDebug
./gradlew spotlessCheck
./gradlew detekt
./gradlew test
```

Targeted tests:

```bash
./gradlew testDebugUnitTest --tests "com.example.MyTest"
./gradlew testDebugUnitTest --tests "com.example.MyTest.myMethod"
./gradlew connectedAndroidTest
```

Style:

- Keep UI state flow explicit (Compose + ViewModel boundaries)
- Prefer immutable state and predictable updates
- Keep long-running work off main thread

Naming:

- Types/objects: `PascalCase`
- Methods/properties: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

Errors:

- Model expected failures explicitly (sealed results/typed errors)
- Keep logs safe and scrub secrets/PII
