# Steam gaming platform.
# Controlled by: features.gaming
{ lib, features, ... }:
{
  config = lib.mkIf features.gaming {
    programs.steam.enable = true;
  };
}
