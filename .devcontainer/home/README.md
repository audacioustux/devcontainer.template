# `home/` — files copied into `$HOME` on every create

`$HOME` inside a devcontainer is container rootfs, not a mount. Only
`/workspaces` and a few VS Code paths survive; **everything else in `$HOME` is
destroyed on every rebuild.** Anything that must outlive a rebuild belongs here
and is re-applied by `task devcontainer:home:setup`.

Contents are copied with `rsync` preserving this layout, so `home/.config/foo`
lands at `~/.config/foo`.

## What belongs here

- `.zshrc` and other shell configuration
- `.ssh/authorized_keys`, if you SSH into the container
- Any dotfile you would otherwise re-create by hand after a rebuild

## What does not

**Never commit private keys, tokens, or `.ssh/id_*`.** This directory is tracked
by git and inherits the repository's visibility. `.gitignore` blocks the common
private-key names as a backstop, but that is a safety net, not permission to
try — a key pushed once must be treated as compromised and rotated, even if the
commit is later removed.

Public keys (`.ssh/authorized_keys`, `*.pub`) are fine.

## Permissions

Git records only the exec bit, so a fresh clone materialises `0644`/`0755`
regardless of what you committed. `home:setup` therefore forces `D700,F600` when
copying `.ssh/`; without that, `rsync -a` would relax an existing `~/.ssh` to
world-readable and sshd's `StrictModes` would then refuse to use it.
