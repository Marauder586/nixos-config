# ============================================================
# Feature Toggles — mochi (physical AMD workstation)
# ============================================================
# Set a flag to false to exclude that group of packages/services.
# Rebuild: sudo nixos-rebuild switch --flake .#mochi
# ============================================================
{
  # ── System features (NixOS only) ─────────────────────────
  desktop = true; # GNOME desktop + X11 + Stylix theming
  audio = true; # PipeWire audio
  virtualization = true; # KVM / QEMU / libvirt
  gaming = true; # Steam
  localAi = true; # Ollama (Vulkan/AMD) + Open-WebUI
  remoteAi = true; # Claude Code
  tailscale = true; # Tailscale VPN daemon

  # ── User features (home-manager) ─────────────────────────
  hyprland = true; # Hyprland + Alacritty + Firefox
  development = true; # Helix + 70+ LSPs + network tooling
  communication = true; # Signal Desktop + Vesktop (Discord)
  monitoring = true; # htop / iotop / sensors / strace / pciutils
  k8sUtil = true; # kubectl + k9s
  codingAgent = true; # opencode + aider + goose + crush + skills
  comfyui = true; # ComfyUI image / 3D generation service

  # ── Endpoints (consumed by coding-agent) ──────────────────
  # On the host itself everything is on localhost.
  ollamaHost = "http://127.0.0.1:11434";
  comfyuiHost = "http://127.0.0.1:8188";
  openWebuiHost = "http://127.0.0.1:8080";
}
