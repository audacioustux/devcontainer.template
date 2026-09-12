# DevContainer + Nix Flake Template

A development environment that is reproducible (**Nix flakes**), portable
(**DevContainers**), and works the same locally, in a container, and in
**GitHub Codespaces**.

Everything optional ships commented out and tagged `OPTIONAL`, with a note on
what it costs and what else must change to enable it. Turn on what you need;
delete what you never will.

## Quick start

1. Click **Use this template**, then clone your repository.
2. Open in VS Code and choose **Reopen in Container**
   (or **Code → Codespaces → Create codespace**).
3. Edit `flake.nix` to add the packages your project needs, then
   **Rebuild Container**.

Without a container, if you have Nix locally:

```bash
nix develop        # or: direnv allow
```

## Layout

```
.
├── .devcontainer/
│   ├── Dockerfile          # Image build: Nix, then the flake environment
│   ├── devcontainer.json   # Features, VS Code settings, lifecycle hooks
│   ├── env.nix             # flake-compat bridge used during the build
│   ├── Taskfile.yml        # Lifecycle hook implementations
│   ├── home/               # Files copied into $HOME on every create
│   └── sshd/               # OPTIONAL sshd hardening
├── flake.nix               # Package list (the file you edit most)
├── Taskfile.yml            # Generic dev tasks, usable without a container
├── .envrc                  # direnv: loads the flake environment
└── .gitignore
```

## Turning things on

| Want | Uncomment |
|---|---|
| A language or tool | its line in `flake.nix` → Rebuild Container |
| A VS Code extension | its line in `devcontainer.json` → `extensions` |
| SSH into the container | `sshd` feature + the `COPY` in `Dockerfile` |
| Docker inside the container | `docker-in-docker` feature |
| Rootless podman | `uidmap` in `Dockerfile` + `--privileged` in `runArgs` |
| Push to GHCR from Codespaces | `"packages": "write"` |

Ports are usually best left to `forwardPorts`, which VS Code forwards on demand.
Use `runArgs` only for what it cannot forward, such as UDP.

## How the pieces fit

**`flake.nix` is the single source of packages.** `env.nix` re-exports it
through `flake-compat` so the Docker build can install the same closure without
enabling experimental features, and `nix develop` uses it directly. One list,
three consumers.

**Lifecycle hooks map one-to-one onto tasks.** `"postCreateCommand": "task
devcontainer:postCreate"` runs the task of that name, so the wiring is literal
rather than something you have to trace:

| Hook | When | Does |
|---|---|---|
| `postCreate` | once, on create | project setup + `$HOME` files |
| `updateContent` | create, rebuild, prebuild | rebuild the Nix profile |
| `postStart` | every start, including resume | submodules, background processes |

Generic work lives in the root `Taskfile.yml` as `dev:*` and runs fine outside a
container; only container-specific steps live in `.devcontainer/Taskfile.yml`.

**`$HOME` does not survive a rebuild.** Only `/workspaces` and a few VS Code
paths are mounted. Anything that must outlive a rebuild belongs in
`.devcontainer/home/`, which `postCreate` copies back — see the README there,
especially before putting anything private in it.

## Two things worth knowing

**Nix profile refresh.** The image bakes a profile entry named `devcontainer`
with no source URL, so `nix profile upgrade` cannot refresh it.
`updateContent` removes and reinstalls it instead, building first so a broken
flake fails before the old profile is gone. If you change the `nix profile
install` line in the `Dockerfile`, change it there too.

**Reclaiming disk.** Each profile generation pins a store closure as a GC root,
so switching flake revisions leaves orphaned closures that are not collected
automatically. `task devcontainer:clean` wipes profile history and runs
`nix store gc`.

## License

MIT
