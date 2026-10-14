{
  self,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.tmux = inputs.wrapper-modules.wrappers.tmux.wrap {
      inherit pkgs;
      runtimePkgs = [
        pkgs.fzf
        pkgs.navi
        pkgs.wl-clipboard
        pkgs.tmux
      ];
      prefix = "C-a";
      vimVisualKeys = true;
      mouse = true;
      terminal = "screen-256color";
      historyLimit = 50000;
      escapeTime = 0;
      shell = lib.getExe self'.packages.fish;

      configAfter = ''
        bind | split-window -h
        bind - split-window -v

        bind c new-window -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R

        set -g renumber-windows on
        setw -g automatic-rename on

        set -as terminal-features ",*:RGB"
        set-environment -g NAVI_PATH "$HOME/notes/cheats"

        bind-key -N "Open Navi (cheat sheets)" -T prefix C-g display-popup -E -d "#{pane_current_path}" -w 90% -h 80% \
          'navi --print | tmux load-buffer -b navi - ; tmux paste-buffer -p -b navi -d'
      '';

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        vim-tmux-navigator
        {
          plugin = catppuccin;
          configAfter = ''
            set -g status-right-length 100
            set -g status-left-length 100
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_application}"
            set -agF status-right "#{E:@catppuccin_status_cpu}"
            set -agF status-right "#{E:@catppuccin_status_ram}"
            set -ag status-right "#{E:@catppuccin_status_session}"
            set -ag status-right "#{E:@catppuccin_status_uptime}"
            set -agF status-right "#{E:@catppuccin_status_battery}"
          '';
        }
        {
          plugin = tmux-which-key;
          configAfter = ''
            set -g @tmux-which-key-xdg-enable 1;

            # Disables building the tmux configuration from YAML everytime the plugin starts.
            # The home manager module calls `plugin/build.py` on each generation.
            set -g @tmux-which-key-disable-autobuild 1

            # Follows nixpkgs prefered path for plugins instead of the default
            # path of `/tmux/plugins/tmux-which-key`.
            set -g @tmux-which-key-xdg-plugin-path tmux-plugins/tmux-which-key
          '';
        }
        cpu
        battery
        extrakto
      ];
    };
  };
}
