# ============================================================
# Feature Toggles — mochi (physical AMD workstation)
# ============================================================
# Set a flag to false to exclude that group of packages/services.
# Rebuild: sudo nixos-rebuild switch --flake .#mochi
# ============================================================
{
  # ── System features (NixOS only) ─────────────────────────
  desktop        = true;  # GNOME desktop + X11 + Stylix theming
  audio          = true;  # PipeWire audio
  virtualization = true;  # KVM / QEMU / libvirt
  gaming         = true;  # Steam
  ai             = true;  # Ollama (Vulkan/AMD) + Open-WebUI
  tailscale      = true;  # Tailscale VPN daemon

  # ── User features (home-manager) ─────────────────────────
  hyprland      = true;  # Hyprland + Alacritty + Firefox
  development   = true;  # Helix + 70+ LSPs + network tooling
  communication = true;  # Signal Desktop + Vesktop (Discord)
  monitoring    = true;  # htop / iotop / sensors / strace / pciutils
}
