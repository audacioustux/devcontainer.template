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
# --shims rather than a bare `mise activate zsh`, which is the usual advice and
# does not work here. Bare activation adjusts PATH from a precmd hook, and in
# this environment direnv and the Nix profile re-prepend their own entries on
# every prompt, after mise. Measured with jq pinned to 1.7.1: bare activation
# still resolved the Nix 1.8.1 even in an interactive shell, while --shims
# resolved 1.7.1. Shims are a fixed directory, so nothing can reorder them away.
(( $+commands[mise] )) && eval "$(mise activate zsh --shims)" || true
