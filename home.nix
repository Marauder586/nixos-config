# Home-manager entry point.
# All configuration lives in modules/home/.
# Toggle features in features.nix.
{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:

{
  imports = [
    ./modules/home/core.nix
    ./modules/home/desktop.nix
    ./modules/home/development.nix
    ./modules/home/communication.nix
    ./modules/home/monitoring.nix
    ./modules/home/virtualization.nix
  ];

  home.username    = "marauder";
  home.homeDirectory = "/home/marauder";
  home.sessionVariables = {
    EDITOR = "hx";
  };

  # colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;

  # Import files from the current configuration directory into the Nix store,
  # and create symbolic links pointing to those store files in the Home directory.

  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # Import the scripts directory into the Nix store,
  # and recursively generate symbolic links in the Home directory pointing to the files in the store.
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "Alt_L";
      bind = [
        "$mod, ENTER, exec, alacritty"
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
          in
          [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        ) 9
      ));
    };
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = (with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    fastfetch

    # archives
    zip
    xz
    unzip

    # utils
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    htop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    wl-clipboard
    xclip

    # Communication Apps
    signal-desktop

    # Basic Terminal Apps
    file
    gawk
    gnused
    gnutar
    gnupg
    jq
    ripgrep
    tree
    which
    yq-go
    zstd

    # VPN
    tailscale

    # Virtualization
    gnome-boxes
    dnsmasq
    phodav

    # 3D
    blender
    freecad
    lycheeslicer



    # Laser Cutting
    inkscape
    lightburn

    # Arduino Tests
    cmatrix
    nmap
    figlet
    btop
  ]) ++
  (with pkgs-unstable; [
    zellij
  ]);


  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "marauder";
        email = "njdeary@yahoo.com";
      };
      core = {
        editor = "hx";
        excludesfile = "~/.gitignore";
        pager = "bat --paging auto";
      };
      column.ui = "auto";
      init.defaultBranch = "main";
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
    };
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.search.defaultenginename" = "ddg";
          "browser.search.order.1" = "ddg";
        };
        search = {
          force = true;
          default = "ddg";
          order = [
            "ddg"
            "google"
          ];
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
        extensions = {
          force = true;
          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            bitwarden
            decentraleyes
            istilldontcareaboutcookies
            privacy-badger
            ublock-origin
            videospeed
          ];
        };
      };
    };
  };

  stylix.autoEnable = true;
  stylix.targets.firefox = {
    enable = true;
    colorTheme.enable = true;
    profileNames = [ "default" ];
  };
  stylix.targets.zellij.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "nicoulaj";
      
    };

    shellAliases = {
      shx = "sudoedit";
    };

    initContent = ''
      eval "$(zellij setup --generate-auto-start zsh)"
    '';
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
