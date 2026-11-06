{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      git-hooks,
      ...
    }:
    # git-hooks.nix supports exactly these systems, so they are the template's.
    # Intel Macs (x86_64-darwin) are out; drop the hooks to bring them back.
    flake-utils.lib.eachSystem
      [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          # --- Git hooks ---
          # Installed when the dev shell is entered, and run by `nix flake check`.
          # Add hooks to the set below. Keep the default stage: with
          # `default_stages = [ "pre-push" ]` the stock check runs no hook and
          # always passes. The installer owns .git/hooks and clears
          # core.hooksPath, so drop this block before adopting husky or lefthook.
          gitHooks = git-hooks.lib.${system}.run {
            src = ./.;
            hooks.nixfmt.enable = true;
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
            # nodejs_22       # also required by pm2, below
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
            # pm2 needs nodejs_22 above uncommented too.
            # pm2
            # cloudflared

            # ── Version management ───────────────────────────────────────────
            # mise reads mise.toml. Its shell activation in
            # .devcontainer/home/.zshrc is already guarded on the binary, so
            # uncommenting here is all that is needed.
            # mise

            # Utilities
            curl
            wget
            tree
            moreutils
            hadolint # lints .devcontainer/Dockerfile; see `task lint`
            rsync # required by devcontainer:home:setup

            # Fun: prints a banner on `nix develop`. Drop these two together with
            # the shellHook below if you would rather have a silent shell.
            figlet
            lolcat
          ];
        in
        {
          # Reads git-tracked files only: `git add` a new file before the check sees it.
          checks.git-hooks = gitHooks;

          # Development Shell (nix develop)
          devShells.default = pkgs.mkShell {
            packages = devPackages;
            shellHook = ''
              ${gitHooks.shellHook}
              figlet "DevEnv" | lolcat
            '';
          };

          # Export for Container (env.nix)
          containerDependencies = devPackages;
        }
      );
}
