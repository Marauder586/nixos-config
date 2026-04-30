# Home-manager standalone config for WSL (Ubuntu 24.04 + nix package manager).
# Terminal-safe modules only — no GUI apps.
# Rebuild: home-manager switch --flake .#balin@ubuntu-nix
{ pkgs, ... }:
{
  imports = [
    ../../modules/home/core.nix
    ../../modules/home/development.nix
    ../../modules/home/monitoring.nix
  ];

  home.username      = "balin";
  home.homeDirectory = "/home/balin";
  home.stateVersion  = "25.11";

  # Stylix: Catppuccin Mocha — auto-themes all enabled programs
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.image        = ../../comfy-home.png;
  stylix.autoEnable   = true;
}
