# Development utilities

Shared wrappers for Bash, Fish, Git, direnv, tmux, Codex, Neovim and Ghostty,
copied from `nixos`. Excludes Noctalia, Niri and wlr-which-key.
Supports `x86_64-linux` and `aarch64-linux`.

`nix develop` provides the Bash utilities and opens Fish through
`bash -ic 'exec …/fish'`. It includes Neovim, Codex, Git and tmux, along with
the command-line tools declared in the Bash wrapper.

Packages are available as `packages.<system>.<name>`. Configurable modules
are exported through `wrappers`, `baseWrappers` and `modules.nvim`,
with configuration fragments in `wrapperTemplates`.

## Templates

From your project directory:

```sh
nix flake init -t github:oscarmampel/dev-utils#ruby
# Alternatives: #python, #go, #rust
git add flake.nix .ruby-version
nix develop
```

Python uses `.python-version` instead of `.ruby-version`. Go and Rust do not
require a version file. Ruby retains the private MySQL service from the
`devenv` template.

All four templates use `devenv.flakeModules.containerDevShell` to run the
environment in rootless containers and require Podman configured on the
host. They also import `dev-utils.flakeModules.development`, which adds the
Bash wrapper, its utilities and the interactive Fish startup.
Language dependencies are added through `devshell.packages`.

To customize Bash, import `inputs.dev-utils.wrappers.bash` into a
`nix-wrapper-modules` module and configure `bash.extraPackages`. The base
modules let you configure Fish, direnv, Codex and Ghostty as in the original
repository. Git reads `GIT_ENV_FILE` at runtime when it is set.

To test templates with local changes before publishing:

```sh
nix develop --override-input dev-utils path:/path/to/dev-utils \
  --override-input container-devshell path:/path/to/devenv
```
