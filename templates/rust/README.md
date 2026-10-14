# Rust project template

Run `nix develop` to enter the rootless development container with rustc,
Cargo, rustfmt, Clippy and rust-analyzer. The Rust source path is configured
for rust-analyzer. Manage dependencies with Cargo as usual.

The shared development module supplies Bash, Fish, Neovim, Codex, Git,
tmux and the Bash wrapper utilities. Interactive sessions run
`bash -ic 'exec …/fish'`. Rootless Podman must be configured on the host.
