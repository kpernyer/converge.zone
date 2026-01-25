# Multi-stage build for tiny Rust Axum service
FROM rustlang/rust:nightly-slim as builder

WORKDIR /app
# Cache deps
COPY rust-pdp-cedar/Cargo.toml rust-pdp-cedar/Cargo.lock* ./
RUN mkdir -p src && echo 'fn main(){}' > src/main.rs &&     cargo build --release && rm -rf src

# Build actual app
COPY rust-pdp-cedar/ ./
RUN cargo build --release

# Runtime image
FROM debian:stable-slim
RUN useradd -m appuser
WORKDIR /app
COPY --from=builder /app/target/release/pdp-cedar /app/pdp-cedar
COPY --from=builder /app/policies /app/policies
ENV REDIS_URL=redis://redis:6379
EXPOSE 8080
USER appuser
ENTRYPOINT ["/app/pdp-cedar"]
