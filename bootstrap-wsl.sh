#!/usr/bin/env bash
# Bootstrap a minimal Debian/Ubuntu install into the wsl-nix home-manager config.
# Run once as a regular user with sudo privileges.
set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step()  { echo -e "\n${GREEN}==> $*${NC}"; }
warn()  { echo -e "${YELLOW} !  $*${NC}"; }
die()   { echo -e "${RED}ERR $*${NC}" >&2; exit 1; }
pause() { echo -e "\n${YELLOW}$*${NC}"; read -rp "    Press Enter to continue..."; }

[[ $EUID -eq 0 ]] && die "Run as a regular user, not root."

# ── 1. Apt dependencies ──────────────────────────────────────────────────────
step "Installing apt dependencies..."
sudo apt-get update -qq
sudo apt-get install -y \
  curl \
  xz-utils \
  git \
  ca-certificates \
  openssh-client \
  unzip \
  wget

# ── 2. Nix (Determinate Systems installer) ───────────────────────────────────
step "Installing Nix..."
if command -v nix &>/dev/null; then
  warn "Nix already installed — skipping."
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
fi

# Source nix into this shell session
NIX_PROFILE=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if [[ -e $NIX_PROFILE ]]; then
  # shellcheck source=/dev/null
  . "$NIX_PROFILE"
else
  die "Nix profile script not found — installation may have failed."
fi

# Enable flakes and nix-command for this user
mkdir -p ~/.config/nix
if ! grep -q 'experimental-features' ~/.config/nix/nix.conf 2>/dev/null; then
  echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
fi

# ── 3. SSH key ────────────────────────────────────────────────────────────────
step "Setting up SSH key..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh

if [[ -f ~/.ssh/id_ed25519 ]]; then
  warn "SSH key already exists at ~/.ssh/id_ed25519 — skipping generation."
else
  ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
  echo -e "\n${GREEN}Generated new SSH key.${NC}"
fi

echo ""
echo "────────────────────────────────────────────────"
echo "  Public key:"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""
echo "  Add it to GitHub: https://github.com/settings/ssh/new"
echo "────────────────────────────────────────────────"

pause "Add the key to GitHub, then press Enter."

step "Testing GitHub SSH connection..."
# Accept the host key automatically on first connect, then verify auth
ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 \
  | grep -q "successfully authenticated" \
  || warn "Could not confirm GitHub auth — continuing anyway. Check your key if the clone fails."

# ── 4. Clone nixos-config ────────────────────────────────────────────────────
step "Cloning nixos-config..."
if [[ -d ~/nixos-config/.git ]]; then
  warn "~/nixos-config already exists — skipping clone."
else
  git clone git@github.com:Marauder586/nixos-config.git ~/nixos-config
fi

# ── 5. Build wsl-nix home-manager config ─────────────────────────────────────
step "Building home-manager config (this will take a while on first run)..."
nix run github:nix-community/home-manager/release-25.11 -- \
  switch --flake ~/nixos-config#marauder@wsl-nix

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Bootstrap complete.${NC}"
echo "Start a new shell (or run: exec \$SHELL) to load the full environment."
