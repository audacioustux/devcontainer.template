# Path to Oh My Zsh installation (managed by devcontainer feature)
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    zoxide
    direnv
)

source $ZSH/oh-my-zsh.sh

# OPTIONAL — mise shims, if you enabled mise in flake.nix.
#
# Guarded because mise is commented out by default; an unguarded eval would
# break every shell in a template that does not use it.
#
# This line is what makes `task mise:setup` mean anything. Installing a tool
# only puts it under ~/.local/share/mise/installs; without this the shell keeps
# resolving whatever was already on PATH, so `mise current` reports the pinned
# version while the binary you actually run is a different one.
#
# --shims rather than a bare `mise activate zsh`, which is the usual advice.
# Measured in a real interactive shell with jq pinned to 1.7.1: after bare
# activation the precmd hook is installed and PATH gains no tool directory at
# all, so jq still resolved to 1.8.1 from the Nix profile. With --shims the
# shim directory is on PATH from the moment it is evaluated, and jq resolved to
# the pinned 1.7.1.
#
# If you hit this, check `mise trust` first. An untrusted mise.toml makes mise
# refuse to parse it and report nothing usable, which looks exactly like a PATH
# problem and is not one.
(( $+commands[mise] )) && eval "$(mise activate zsh --shims)" || true
