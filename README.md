# DevContainer + Nix Flake Template

A template repository for development environments using **DevContainers** with **Nix Flakes**.

## Features

- 🐳 **DevContainer** - Consistent development environment across machines
- ❄️ **Nix Flakes** - Reproducible package management
- 🚀 **GitHub Codespaces** - Ready for cloud development
- 🔧 **VS Code Integration** - Pre-configured extensions and settings
- 📦 **direnv** - Automatic environment loading

## Quick Start

### Use as Template

1. Click "Use this template" on GitHub
2. Clone your new repository
3. Open in VS Code with Dev Containers extension
4. Click "Reopen in Container"

### GitHub Codespaces

Click "Code" → "Codespaces" → "Create codespace on main"

## Customization

### Add Packages

Edit `flake.nix` and add packages to the `devPackages` list:

```nix
devPackages = with pkgs; [
  # Your packages here
  nodejs_22
  python311
  rustc
];
```

Then rebuild the container.

### VS Code Extensions

Edit `.devcontainer/devcontainer.json` under `customizations.vscode.extensions`.

## Structure

```
.
├── .devcontainer/
│   ├── Dockerfile       # Container build with Nix
│   ├── devcontainer.json # VS Code/Codespaces config
│   ├── env.nix          # Flake-compat bridge
│   └── .zshrc           # Shell configuration
├── flake.nix            # Nix package definitions
├── flake.lock           # Locked dependencies
├── Taskfile.yml         # Dev task automation
├── .envrc               # direnv configuration
└── .gitignore
```

## Local Development (without container)

If you have Nix installed locally:

```bash
# Enter development shell
nix develop

# Or with direnv (automatic)
direnv allow
```

## License

MIT
