// OPTIONAL — long-running background processes for this devcontainer, managed
// by PM2 and started from `task dev:start` (the postStart hook).
//
// Delete this file if the container needs no background processes; `pm2:up`
// no-ops when it is absent.
//
// Why PM2 rather than `&` or a systemd unit: the container has no init system,
// postStart runs on every resume, and a bare background process leaves no way
// to see why it died. PM2 gives restart policy, log capture, and `pm2 describe`.
//
// Everything below is commented out. Uncomment an app, or write your own using
// the same shape.

// ---------------------------------------------------------------------------
// Example: expose this container's sshd through a Cloudflare Tunnel.
//
// Requires: the `sshd` feature in devcontainer.json, `cloudflared` uncommented
// in flake.nix, and TUNNEL_TOKEN set in .env (see .env.example).
//
// READ THIS BEFORE POINTING IT AT AN EXISTING TUNNEL. A devbox must run its
// OWN tunnel, with its own UUID and token. Pointing a second connector at a
// tunnel that already serves something else does not "reuse" it — Cloudflare
// load-balances that tunnel's traffic across every connector, so this container
// would start serving that deployment's production requests.
//
// const sshTunnel = {
//   name: "devbox-tunnel",
//   script: "cloudflared",
//   // `--config` is a global flag and must precede the `tunnel` subcommand.
//   // Absolute path: pm2's cwd is not guaranteed to be the repo root.
//   args: [
//     "--no-autoupdate",
//     "--config",
//     `${__dirname}/.devcontainer/cloudflared.yml`,
//     "--metrics",
//     "127.0.0.1:20241",
//     "tunnel",
//     "run",
//   ],
//   interpreter: "none",
//   autorestart: true,
//   // Without a usable token cloudflared exits immediately, so back off rather
//   // than spin at the default fixed delay. This is what makes a missing or
//   // rejected token surface as a visibly failed app instead of a silent hot
//   // loop: a few restarts, then the log says exactly what is wrong.
//   exp_backoff_restart_delay: 5000,
// };

// The token is read ambiently from the environment — TUNNEL_TOKEN is the name
// cloudflared itself looks for, and PM2 passes its environment through, so no
// `env` block is needed.
//
// It reaches non-interactive lifecycle hooks via `dotenv` in the root Taskfile,
// NOT via direnv: direnv exports on precmd, which a hook's non-interactive
// shell never fires. That is why the Taskfile loads .env itself.

module.exports = {
  apps: [
    // sshTunnel,
  ],
};
