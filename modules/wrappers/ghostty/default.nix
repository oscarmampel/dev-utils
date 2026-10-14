{...}: {
  flake.baseWrappers.ghostty = {
    config,
    lib,
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.modules.default];

    options.settings = lib.mkOption {
      type = lib.types.attrs;
      description = "Ghostty configuration.";
      default = {};
    };

    config = {
      package = pkgs.ghostty;
      filesToExclude = [
        "share/applications/com.mitchellh.ghostty.desktop"
      ];
      constructFiles = {
        generatedConfig = {
          content =
            lib.generators.toKeyValue {
              listsAsDuplicateKeys = true;
            }
            config.settings;
          relPath = "share/ghostty-wrapper/config";
        };

        "ghostty.desktop" = {
          content = ''
            [Desktop Entry]
            Version=1.0
            Name=Ghostty
            Type=Application
            Comment=A terminal emulator
            TryExec=ghostty
            Exec=ghostty
            Icon=com.mitchellh.ghostty
            Categories=System;TerminalEmulator;
            Keywords=terminal;tty;pty;
            StartupNotify=true
            StartupWMClass=com.mitchellh.ghostty
            Terminal=false
            Actions=new-window;
            X-GNOME-UsesNotifications=true
            X-TerminalArgExec=-e
            X-TerminalArgTitle=--title=
            X-TerminalArgAppId=--class=
            X-TerminalArgDir=--working-directory=
            X-TerminalArgHold=--wait-after-command
            DBusActivatable=true
            X-KDE-Shortcuts=Ctrl+Alt+T

            [Desktop Action new-window]
            Name=New Window
            Exec=ghostty --gtk-single-instance=tru
          '';
          relPath = "share/applications/ghostty.desktop";
        };
      };
      flags = {
        "--config-default-files" = "false";
        "--config-file" = config.constructFiles.generatedConfig.path;
      };
      flagSeparator = "=";
      env = {
        GTK_IM_MODULE = "simple";
      };
      prefixVar = [
        ["XDG_DATA_DIRS" ":" "${pkgs.nerd-fonts.hack}/share"]
      ];
    };
  };
}
