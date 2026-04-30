# This file is no longer used.
# The NixOS entry point is now hosts/mochi/default.nix,
# imported directly by flake.nix.
#
# If nixos-rebuild is pointing here, update /etc/nixos to point at
# the flake in this directory and rebuild with:
#   sudo nixos-rebuild switch --flake /path/to/nixos-config#mochi
{ ... }: { }
