# converge-www

**Website and Documentation**

## Purpose

converge-www is the public website for Converge at [converge.zone](https://converge.zone). It provides documentation, examples, API references, and the public face of the platform.

## Why It Matters

A platform needs a front door. converge-www provides:

- **Documentation**: Concepts, tutorials, API references
- **Examples**: Sample flows, integration guides
- **Marketing**: Value proposition, use cases, pricing
- **Support**: Contact, community, issue reporting

This is how potential users discover, evaluate, and onboard to Converge.

## Place in the Platform

converge-www is the public interface:

```
Public Internet
    ↓
converge-www  ←── converge.zone website
    │
    ├── Documentation (concepts, tutorials)
    ├── API Reference (generated from code)
    ├── Examples (sample flows)
    └── Marketing (value prop, pricing)
```

The website is deployed separately from the runtime and serves static content.

## Technology

- **Framework**: Modern TypeScript/React stack
- **Hosting**: Cloudflare Pages / Firebase
- **Documentation**: MDX for rich content
- **API Docs**: Generated from Rust doc comments

## Governance Alignment

Even the website reflects Converge principles:

- **Transparency**: Clear documentation of how the system works
- **Traceability**: Version-tagged documentation matching releases
- **Institutional Clarity**: Explicit about what Converge does and doesn't do

This is how Converge presents itself as institutional infrastructure, not a chatbot wrapper.
