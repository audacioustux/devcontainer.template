# Base image: Ubuntu 24.04 (Noble)
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- Phase 1: Root Operations ---
# xz-utils follows the floating Ubuntu Noble repository version; nix's installer needs it.
#
# uidmap is OPTIONAL — keep it only if you run rootless containers (podman, docker-in-docker)
# inside this devcontainer. It ships the **setuid** /usr/bin/newuidmap and /usr/bin/newgidmap
# (-rwsr-xr-x) that rootless podman needs to build a user namespace. It cannot come from nix:
# the store is read-only and unprivileged, so nix's own `shadow` binaries are plain
# -r-xr-xr-x and podman fails with "should have setuid or have filecaps setuid".
#
# Declare it here rather than installing it in a running container: an undeclared binary
# dropped into /usr/local/bin is owned by no package and vanishes on the next rebuild.
#
# Caveat if you keep it: the ENV PATH lines below put ~/.nix-profile/bin ahead of /usr/bin
# for every shell, so nix's non-setuid newuidmap SHADOWS this one by default. Callers that
# need the setuid copy must prepend /usr/bin themselves rather than trusting PATH order.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        xz-utils \
        uidmap \
    && rm -rf /var/lib/apt/lists/*

# Set default shell to zsh (the base image ships it; the devcontainer feature configures it)
RUN chsh -s /bin/zsh vscode

# 1. Prepare /nix directory for single-user install
RUN mkdir -m 0755 /nix \
    && chown vscode:vscode /nix

# --- OPTIONAL: sshd hardening -------------------------------------------------
# Uncomment together with the `sshd` feature in devcontainer.json. Only needed if
# you expose this container's sshd beyond localhost (e.g. via a tunnel). Drop the
# file at .devcontainer/sshd/10-devbox.conf; rationale belongs in that file.
#
# COPY --chmod=644 .devcontainer/sshd/10-devbox.conf /etc/ssh/sshd_config.d/
# ------------------------------------------------------------------------------

# --- Phase 2: User Operations ---
# Switch to non-root user
USER vscode
ENV USER=vscode
ENV HOME=/home/vscode

# 2. Enable Flakes for user (required for build & VS Code)
RUN mkdir -p ~/.config/nix && cat <<EOF >> ~/.config/nix/nix.conf
experimental-features = nix-command flakes
download-buffer-size = 536870912
auto-optimise-store = true
EOF

# 3. Install Nix (Single-User, no daemon)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Add Nix to PATH for subsequent steps
ENV PATH="/home/vscode/.nix-profile/bin:$PATH"
ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# --- Phase 3: Environment Installation ---
WORKDIR /tmp/build

# 4. Copy context (preserve structure for env.nix resolution)
COPY --chown=vscode:vscode flake.nix flake.lock ./
COPY --chown=vscode:vscode .devcontainer/env.nix .devcontainer/

# 5. Install environment (build flake & install packages)
#
# This bakes a profile entry named `devcontainer`. It carries no source URL, so
# `nix profile upgrade` cannot refresh it — `task devcontainer:updateContent`
# removes and reinstalls it instead. Keep the two in sync if you change this line.
RUN nix profile install --impure --accept-flake-config --file .devcontainer/env.nix

# 6. Cleanup
WORKDIR /
RUN rm -rf /tmp/build

# 7. Persist PATH for interactive shell
ENV PATH="/home/vscode/.nix-profile/bin:$PATH"
