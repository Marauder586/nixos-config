# Tailscale VPN daemon.
# Controlled by: features.tailscale
{ lib, features, ... }:
{
  config = lib.mkIf features.tailscale {
    services.tailscale.enable = true;
  };
}
