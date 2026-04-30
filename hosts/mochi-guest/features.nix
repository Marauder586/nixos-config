# ============================================================
# Feature Toggles — mochi-guest (QEMU/KVM virtual machine)
# ============================================================
# Set a flag to false to exclude that group of packages/services.
# Rebuild: sudo nixos-rebuild switch --flake .#mochi-guest
# ============================================================
{
  # ── System features (NixOS only) ─────────────────────────
  desktop        = true;   # GNOME desktop + X11 + Stylix theming
  audio          = true;   # PipeWire audio
  virtualization = false;  # guests don't run nested VMs
  gaming         = false;  # no GPU passthrough in guest
  "local-ai"     = false;  # too resource-heavy for a VM
  "remote-ai"    = false;
  tailscale      = true;   # Tailscale VPN daemon

  # ── User features (home-manager) ─────────────────────────
  hyprland      = true;  # Hyprland + Alacritty + Firefox
  development   = true;  # Helix + 70+ LSPs + network tooling
  communication = true;  # Signal Desktop + Vesktop (Discord)
  monitoring    = true;  # htop / iotop / sensors / strace / pciutils
}
