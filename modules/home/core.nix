# Always-on user configuration.
# Git, shell (bash + zsh), and essential CLI tools that belong on every machine.
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

    # Modern Unix replacements / core utilities
    eza        # ls replacement
    fzf        # fuzzy finder
    ripgrep    # fast grep
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
        pager        = "bat --paging auto";
      };
      column.ui           = "auto";
      init.defaultBranch  = "main";
      push = {
        default        = "simple";
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
    };
  };

  # ── Bash ──────────────────────────────────────────────────
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    shellAliases = {
      k         = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  # ── Zsh ───────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable  = true;
      plugins = [ "git" ];
      theme   = "nicoulaj";
    };
    shellAliases = {
      shx = "sudoedit";
    };
    initContent = ''
      eval "$(zellij setup --generate-auto-start zsh)"
    '';
  };
}
