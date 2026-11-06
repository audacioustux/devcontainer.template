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
          # Run at pre-push rather than pre-commit, so a commit stays instant and the
          # gate still holds before anything leaves the machine. Add hooks to the set
          # below; the dev shell installs them on entry. The installer owns
          # .git/hooks: it clears core.hooksPath, so drop this block before adopting
          # husky or lefthook.
          stage = "pre-push";
          gitHooks = git-hooks.lib.${system}.run {
            src = ./.;
            default_stages = [ stage ];
            hooks = {
              nixfmt.enable = true;
            };
          };

          enabledHooks = builtins.filter (hook: hook.enable) (builtins.attrValues gitHooks.config.hooks);

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
          # Not `checks.git-hooks = gitHooks`: that check runs the pre-commit stage,
          # so with every hook on pre-push it runs nothing and always passes. This one
          # names the stage. It reads git-tracked files only, so `git add` a new file
          # before expecting the check to see it.
          checks.hooks =
            assert pkgs.lib.assertMsg (enabledHooks != [ ]) "no git hook is enabled";
            assert pkgs.lib.assertMsg (builtins.all (
              hook: builtins.elem stage hook.stages
            ) enabledHooks) "an enabled git hook does not run at ${stage}";
            pkgs.runCommand "hooks-check" { nativeBuildInputs = [ pkgs.git ]; } ''
              export HOME=$TMPDIR
              cp -r --no-preserve=mode ${./.} repo
              cd repo
              git init -q
              git add -A -f
              ${gitHooks.config.package}/bin/pre-commit run --all-files --hook-stage ${stage} \
                --config ${gitHooks.config.configFile} --show-diff-on-failure
              touch $out
            '';

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
