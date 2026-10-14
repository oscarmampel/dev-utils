# Go project template

Run `nix develop` to enter the rootless development container with Go, gopls,
gotools and go-tools. Manage dependencies with `go mod` as usual.

The shared development module supplies Bash, Fish, Neovim, Codex, Git,
tmux and the Bash wrapper utilities. Interactive sessions run
`bash -ic 'exec …/fish'`. Rootless Podman must be configured on the host.
