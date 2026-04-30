# ============================================================
# Feature Toggles — ubuntu-nix (Ubuntu 24.04 + nix package manager)
# ============================================================
# System features (desktop/audio/virtualization/gaming/ai/tailscale) are
# NixOS-only and have no effect here; they are kept for schema consistency.
# Rebuild: home-manager switch --flake .#marauder@wsl-nix
# ============================================================
{
  # ── System features (NixOS only — no-ops here) ───────────
  desktop        = false;
  audio          = false;
  virtualization = false;
  gaming         = false;
  "local-ai"     = false;
  tailscale      = false;

  # ── User features (home-manager) ─────────────────────────
  hyprland      = false;  # Wayland compositor — GUI, not available headless
  development   = true;   # Helix + LSPs + network tooling (all terminal)
  communication = false;  # Signal + Vesktop are GUI apps
  monitoring    = true;   # htop / iotop / strace / pciutils etc. (all terminal)
  "remote-ai"   = true;   # Claude Code
}
