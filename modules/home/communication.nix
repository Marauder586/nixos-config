# Signal Desktop and Vesktop (Discord alternative).
# Controlled by: features.communication
{ pkgs, lib, features, ... }:
{
  imports = lib.optionals features.communication [ ./vesktop ];

  config = lib.mkIf features.communication {
    home.packages = with pkgs; [
      signal-desktop
    ];
  };
}
