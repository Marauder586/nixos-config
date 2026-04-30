# Always-on user configuration.
# Git, shell (bash + zsh), and essential CLI tools that belong on every machine.
# No stylix references here — this module is used on non-NixOS hosts too.
{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "hx";
  };

  # ── Essential CLI tools ───────────────────────────────────
  home.packages = with pkgs; [
    fastfetch

    # Archives
    zip
    xz
    unzip
    zstd

    # Modern Unix replacements (GNU → Rust)
    eza        # ls
    bat        # cat  (programs.bat below manages config)
    fd         # find
    ripgrep    # grep
    sd         # sed  (note: different syntax — use sd 'pat' 'repl' file)
    du-dust    # du   (binary: dust)
    procs      # ps
    bottom     # top  (binary: btm)
    delta      # git pager / diff prettifier
    choose     # cut  (binary: choose)

    # Fuzzy finder + interactive tools
    fzf
    zoxide     # smarter cd (programs.zoxide below manages shell init)

    # Core utilities
    tree
    which
    file
    gawk
    gnused
    gnutar
    gnupg

    # Structured data
    jq
    yq-go

    # Terminal multiplexer
    zellij

    # Nix tooling
    nix-output-monitor

    # Content / docs
    hugo
    glow

    # VPN CLI (daemon is in modules/nixos/networking.nix)
    tailscale
  ];

  # ── bat (cat replacement) ─────────────────────────────────
  # Stylix overrides the theme on NixOS hosts; Dracula is the fallback.
  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };

  # ── zoxide (smarter cd) ───────────────────────────────────
  # Use `z <dir>` to jump, `zi` for interactive selection.
  programs.zoxide = {
    enable                = true;
    enableBashIntegration = true;
    enableZshIntegration  = true;
  };

  # ── Shell aliases (all shells) ────────────────────────────
  # GNU util → Rust equivalent
  home.shellAliases = {
    ls   = "eza --icons=auto --color=always --group-directories-first";
    ll   = "eza -la --icons=auto --git --color=always --group-directories-first";
    la   = "eza -a --icons=auto --color=always --group-directories-first";
    lt   = "eza --tree --icons=auto --color=always";
    cat  = "bat";
    find = "fd";
    grep = "rg";
    du   = "dust";
    ps   = "procs";
    top  = "btm";
  };

  # ── Git ───────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "marauder";
        email = "njdeary@yahoo.com";
      };
      core = {
        editor      = "hx";
        excludesfile = "~/.gitignore";
        pager        = "delta";
      };
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate     = true;
        side-by-side = true;
        line-numbers = true;
      };
      column.ui           = "auto";
      init.defaultBranch  = "main";
      push = {
        default         = "simple";
        autoSetupRemote = true;
        followTags      = true;
      };
      fetch = {
        prune     = true;
        pruneTags = true;
        all       = true;
      };
      help.autocorrect = "prompt";
      rerere = {
        enabled    = true;
        autoupdate = true;
      };
      rebase = {
        autoSquash = true;
        autoStash  = true;
        updateRefs = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";
    };
  };

  # ── Bash ──────────────────────────────────────────────────
  programs.bash = {
    enable           = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    shellAliases = {
      k         = "kubectl";
      shx       = "sudoedit";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  # ── Zsh ───────────────────────────────────────────────────
  programs.zsh = {
    enable            = true;
    enableCompletion  = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable  = true;
      plugins = [ "git" ];
      theme   = "nicoulaj";
    };
    shellAliases = {
      k   = "kubectl";
      shx = "sudoedit";
    };
    initContent = ''
      eval "$(zellij setup --generate-auto-start zsh)"
    '';
  };
}
