{
  system ? builtins.currentSystem,
}:

let
  # `--impure` is already required by the Dockerfile's `nix profile install`
  # invocation, so `getFlake` here needs no extra pin: it reads the same
  # `flake.lock`-resolved inputs as `nix develop` would.
  #
  # This works during the image build even though /tmp/build is not a git
  # checkout — the Dockerfile COPYs only flake.nix, flake.lock and this file.
  # `getFlake` on a plain path copies that directory into the store and
  # evaluates it there; a working tree is not required. Verified by building
  # from a non-git directory holding exactly those three files.
  flake = builtins.getFlake (toString ../.);

  # Reuse the flake's own pinned `nixpkgs` input rather than resolving
  # `<nixpkgs>` from NIX_PATH.
  #
  # This is not a style preference. A single-user Nix install adds no channel
  # and the Dockerfile sets no NIX_PATH, so `import <nixpkgs>` fails outright
  # during the image build with "file 'nixpkgs' was not found in the Nix search
  # path". Where a NIX_PATH does exist it is worse than the error, because the
  # build then silently resolves a different nixpkgs than flake.lock pins.
  pkgs = flake.inputs.nixpkgs.legacyPackages.${system};

  # Read the explicit dependency list exported by flake.nix.
  allDeps = flake.containerDependencies.${system};
in
pkgs.buildEnv {
  # Must match the name used by `nix profile remove` in
  # .devcontainer/Taskfile.yml's updateContent task. `nix profile remove` takes
  # this buildEnv name, and a non-matching name makes it a silent no-op that
  # leaves the baked entry in place for the following install to collide with.
  name = "devcontainer";
  paths = allDeps;
  ignoreCollisions = true;
}
