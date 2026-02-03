# ============================================================================
# Converge Zone - Nix Flake
# ============================================================================
#
# WHAT IS THIS FILE?
# ------------------
# This is a Nix flake - a declarative, reproducible way to define your
# development environment. Think of it as a "package.json for your entire
# system" that works across languages.
#
# WHY NIX?
# --------
# 1. REPRODUCIBILITY: Everyone gets the exact same tool versions
# 2. ISOLATION: Doesn't pollute your system - tools only exist in this project
# 3. CROSS-PLATFORM: Works on macOS, Linux, and WSL
# 4. MULTI-LANGUAGE: One file manages Rust, Elixir, Node, and native deps
#
# GETTING STARTED
# ---------------
# 1. Install Nix (if you haven't):
#    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
#
# 2. Enable flakes (one-time setup):
#    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
#
# 3. Enter the development shell:
#    nix develop
#
# 4. Or use direnv for automatic activation (recommended):
#    echo "use flake" > .envrc && direnv allow
#
# LEARNING PATH
# -------------
# Start simple, add complexity as you need it:
#   Level 1: Use `nix develop` to get a shell with all tools
#   Level 2: Add your own packages to `packages` list below
#   Level 3: Customize shell hooks for project-specific setup
#   Level 4: Add build outputs (packages, Docker images)
#
# ============================================================================

{
  description = "Converge Zone - Deterministic convergence platform";

  # ---------------------------------------------------------------------------
  # INPUTS: Where we get packages from
  # ---------------------------------------------------------------------------
  # Think of these like npm registries, but for everything (not just JS)
  inputs = {
    # nixpkgs: The main Nix package repository (80,000+ packages)
    # Using nixos-unstable for latest tool versions
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # rust-overlay: Provides specific Rust toolchain versions
    # This lets us pin to Rust 1.85+ for edition 2024
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-utils: Helper functions for multi-platform support
    flake-utils.url = "github:numtide/flake-utils";
  };

  # ---------------------------------------------------------------------------
  # OUTPUTS: What this flake provides
  # ---------------------------------------------------------------------------
  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Apply the rust overlay to get access to specific Rust versions
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
          # Allow unfree packages (some tools like vscode extensions)
          config.allowUnfree = true;
        };

        # ---------------------------------------------------------------------
        # RUST TOOLCHAIN
        # ---------------------------------------------------------------------
        # Pin to a specific Rust version for reproducibility
        # Your project requires 1.85+ for edition 2024
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"       # For IDE support and rust-analyzer
            "rust-analyzer"  # LSP for IDE integration
            "clippy"         # Linting
            "rustfmt"        # Formatting
          ];
          targets = [
            # Add cross-compilation targets if needed
            # "wasm32-unknown-unknown"
            # "aarch64-apple-darwin"
          ];
        };

      in {
        # ---------------------------------------------------------------------
        # DEVELOPMENT SHELL
        # ---------------------------------------------------------------------
        # This is what you get when you run `nix develop`
        devShells.default = pkgs.mkShell {
          name = "converge-zone";

          # -------------------------------------------------------------------
          # PACKAGES: Tools available in your shell
          # -------------------------------------------------------------------
          # Add or remove tools here. Search for packages at:
          # https://search.nixos.org/packages
          packages = with pkgs; [
            # -----------------------------------------------------------------
            # Rust ecosystem
            # -----------------------------------------------------------------
            rustToolchain
            cargo-watch       # File watcher for cargo
            cargo-deny        # License and security auditing
            cargo-audit       # Security vulnerability scanner
            cargo-llvm-cov    # Code coverage with LLVM

            # -----------------------------------------------------------------
            # Elixir ecosystem (for converge-ledger)
            # -----------------------------------------------------------------
            elixir_1_17       # Elixir 1.17+
            erlang_27         # Erlang/OTP 27 (required by Elixir 1.17)

            # -----------------------------------------------------------------
            # Node/TypeScript ecosystem (for converge-www)
            # -----------------------------------------------------------------
            bun               # Fast JS runtime and bundler
            nodejs_22         # Node.js 22 LTS (fallback for tools)

            # -----------------------------------------------------------------
            # Build tools
            # -----------------------------------------------------------------
            just              # Command runner (our task system)
            protobuf          # Protocol buffers compiler
            grpcurl           # gRPC CLI tool

            # -----------------------------------------------------------------
            # Native dependencies
            # -----------------------------------------------------------------
            # OR-Tools would go here when we figure out the Nix derivation
            # tesseract       # OCR (optional feature)
            # leptonica       # Image processing (tesseract dep)

            # -----------------------------------------------------------------
            # Development utilities
            # -----------------------------------------------------------------
            git
            gh                # GitHub CLI
            jq                # JSON processor
            yq                # YAML processor
            httpie            # HTTP client (nicer than curl)
            watchexec         # Generic file watcher

            # -----------------------------------------------------------------
            # Observability tools (for local debugging)
            # -----------------------------------------------------------------
            # prometheus       # Uncomment if you want local prometheus
            # grafana          # Uncomment if you want local grafana

            # -----------------------------------------------------------------
            # Database tools
            # -----------------------------------------------------------------
            # redis            # Uncomment if you want local redis CLI
            # postgresql_16    # Uncomment if needed

            # -----------------------------------------------------------------
            # Cloud/Firebase
            # -----------------------------------------------------------------
            # firebase-tools is not in nixpkgs, use: npm install -g firebase-tools
            # Or we could add a shell hook to install it

            # -----------------------------------------------------------------
            # Platform-specific
            # -----------------------------------------------------------------
          ] ++ lib.optionals stdenv.isDarwin [
            # macOS-specific packages
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.SystemConfiguration
            libiconv
          ] ++ lib.optionals stdenv.isLinux [
            # Linux-specific packages
            # openssl
          ];

          # -------------------------------------------------------------------
          # ENVIRONMENT VARIABLES
          # -------------------------------------------------------------------
          # These are set when you enter the shell
          env = {
            # Rust
            RUST_BACKTRACE = "1";
            RUST_LOG = "info";

            # Help rust-analyzer find the rust source
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

            # Elixir
            ERL_AFLAGS = "-kernel shell_history enabled";
            MIX_HOME = "$PWD/.nix-mix";
            HEX_HOME = "$PWD/.nix-hex";
          };

          # -------------------------------------------------------------------
          # SHELL HOOKS
          # -------------------------------------------------------------------
          # Commands that run when you enter the shell
          shellHook = ''
            echo ""
            echo "╔═══════════════════════════════════════════════════════════╗"
            echo "║  CONVERGE ZONE - Development Environment                  ║"
            echo "╚═══════════════════════════════════════════════════════════╝"
            echo ""
            echo "Tools available:"
            echo "  Rust:    $(rustc --version)"
            echo "  Cargo:   $(cargo --version)"
            echo "  Elixir:  $(elixir --version | grep Elixir)"
            echo "  Bun:     $(bun --version)"
            echo "  Just:    $(just --version)"
            echo ""
            echo "Quick commands:"
            echo "  just doctor    - Check environment health"
            echo "  just --list    - Show all available commands"
            echo "  just fmt       - Format all code"
            echo "  just test      - Run all tests"
            echo ""

            # Set up git hooks if not already done
            if [ "$(git config core.hooksPath)" != ".githooks" ]; then
              echo "Setting up git hooks..."
              git config core.hooksPath .githooks
            fi

            # Create .env from example if it doesn't exist
            if [ ! -f .env ] && [ -f .env.example ]; then
              echo "Creating .env from .env.example..."
              cp .env.example .env
              echo "⚠ Remember to fill in your API keys in .env"
            fi
          '';

          # -------------------------------------------------------------------
          # LIBRARY PATHS (for native dependencies)
          # -------------------------------------------------------------------
          # Some Rust crates need to find native libraries
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
            # Add more native libs here if cargo build fails to find them
          ];

          # For macOS
          DYLD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
            pkgs.libiconv
          ];
        };

        # ---------------------------------------------------------------------
        # ADDITIONAL SHELLS (optional)
        # ---------------------------------------------------------------------
        # You can define specialized shells for different tasks

        # Minimal shell for CI (faster to build)
        devShells.ci = pkgs.mkShell {
          packages = with pkgs; [
            rustToolchain
            cargo-deny
            just
          ];
        };

        # Shell for working on just the website
        devShells.www = pkgs.mkShell {
          packages = with pkgs; [
            bun
            nodejs_22
            just
          ];
        };

        # ---------------------------------------------------------------------
        # PACKAGES (optional, for later)
        # ---------------------------------------------------------------------
        # When you want to build actual artifacts with Nix
        # packages.default = ...
        # packages.converge-runtime = ...

        # ---------------------------------------------------------------------
        # APPS (optional, for later)
        # ---------------------------------------------------------------------
        # For `nix run .#something`
        # apps.default = ...
      }
    );
}
