# Home-manager standalone config for Ubuntu 24.04 + nix package manager.
# Only imports terminal-safe modules — no stylix, no GUI apps.
# Rebuild: home-manager switch --flake .#marauder@ubuntu-nix
{ ... }:
{
  imports = [
    ../../modules/home/core.nix
    ../../modules/home/development.nix
    ../../modules/home/monitoring.nix
  ];

  home.username      = "marauder";
  home.homeDirectory = "/home/marauder";
  home.stateVersion  = "25.11";
}
