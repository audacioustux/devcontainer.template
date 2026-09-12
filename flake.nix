{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # --- Package List ---
        # Customize this list for your project
        devPackages = with pkgs; [
          # Core Shell Tools
          zsh
          direnv
          git
          gh
          go-task
          jq
          yq-go
          ripgrep
          fd
          eza
          bat
          zoxide
          fzf

          # Editor
          neovim

          # Nix Tooling
          nixd
          nixfmt

          # ── Languages (uncomment as needed) ──────────────────────────────
          # Prefer one toolchain source per language. If you use mise or rustup
          # to manage versions, do NOT also list the language here — two installs
          # on PATH is a debugging session nobody enjoys.
          # nodejs_22
          # bun
          # deno
          # python313
          # uv
          # go
          # rustup          # version-managed; pairs with rust-toolchain.toml
          # cargo-nextest

          # ── Infra / container tooling (uncomment as needed) ───────────────
          # podman
          # docker-client
          # kubectl
          # k9s
          # opentofu
          # awscli2
          # postgresql
          # redis

          # ── Background processes (uncomment as needed) ────────────────────
          # nodejs_22       # required by pm2
          # pm2             # process manager wired to ecosystem.config.js
          # cloudflared     # tunnel; see .devcontainer/cloudflared.yml

          # ── Version management ───────────────────────────────────────────
          # mise            # per-project tool versions from mise.toml

          # Utilities
          curl
          wget
          tree
          moreutils
          pre-commit
          rsync # required by devcontainer:home:setup

          # Fun: prints a banner on `nix develop`. Drop these two together with
          # the shellHook below if you would rather have a silent shell.
          figlet
          lolcat
        ];
      in
      {
        # Development Shell (nix develop)
        devShells.default = pkgs.mkShell {
          packages = devPackages;
          shellHook = ''
            figlet "DevEnv" | lolcat
          '';
        };

        # Export for Container (env.nix)
        containerDependencies = devPackages;
      }
    );
}
