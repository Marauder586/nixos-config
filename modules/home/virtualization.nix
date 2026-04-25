# User-space virtual machine management tools.
# Pairs with modules/nixos/virtualization.nix (system daemon).
# Controlled by: features.virtualization
{ pkgs, lib, features, ... }:
{
  config = lib.mkIf features.virtualization {
    home.packages = with pkgs; [
      gnome-boxes  # GNOME VM manager GUI
      dnsmasq      # DNS/DHCP for VM networking
      phodav       # WebDAV for VM file sharing (spice-webdavd)
    ];
  };
}
