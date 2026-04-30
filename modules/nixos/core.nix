# Always-on base NixOS configuration.
# Locale, nix settings, networking, shell, and minimal system packages.
{ pkgs, ... }:
{
  # ── Nix ───────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";

  # ── Locale / timezone ─────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # ── Shell (required so user shell is available system-wide) ─
  programs.zsh.enable = true;

  # ── Fonts ─────────────────────────────────────────────────
  # Iosevka Nerd Font provides the glyph coverage needed by eza --icons
  fonts.packages = [ pkgs.nerd-fonts.iosevka ];

  # ── Minimal system packages ───────────────────────────────
  environment.systemPackages = with pkgs; [
    vim
    wget
  ];
}
