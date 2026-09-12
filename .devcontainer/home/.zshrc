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
# Measured in an interactive shell with jq pinned to 1.7.1 and the config
# trusted: bare activation does add its tool directory, but appends it behind
# the Nix profile - the Nix jq sat at PATH position 37 and mise's install dir
# at 90 - so the pinned tool loses and `jq --version` still reported 1.8.1.
# With --shims the shim directory wins and it reported 1.7.1.
#
# One trap if you are debugging this: an untrusted mise.toml makes mise refuse
# to parse it, so no tool directory is added at all and the symptom looks
# identical. Check `mise trust --show` from inside the directory - it reports
# on the current directory, so running it from elsewhere answers about a
# different path.
(( $+commands[mise] )) && eval "$(mise activate zsh --shims)" || true
