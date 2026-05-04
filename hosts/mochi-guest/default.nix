# Machine-specific configuration for "mochi-guest"
# Hardware, boot, hostname, and user account live here.
# Shared behaviour is in modules/nixos/.
{
  pkgs,
  lib,
  features,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/virtualization.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/ai.nix
    ../../modules/nixos/networking.nix
  ];

  # ── SPICE guest agent ─────────────────────────────────────
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;
  systemd.user.services.spice-vdagent = {
    description = "SPICE VD agent";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    environment.DISPLAY = ":0";
    serviceConfig = {
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
      Restart = "on-failure";
      Type = "simple";
    };
  };

  # ── Boot ──────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # kvm-amd kernel module is declared in hardware-configuration.nix
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # ── Identity ──────────────────────────────────────────────
  networking.hostName = "mochi-guest";

  # ── Users ─────────────────────────────────────────────────
  users.users.marauder = {
    isNormalUser = true;
    description = "marauder";
    extraGroups =
      ["networkmanager" "wheel"]
      ++ lib.optionals features.virtualization ["kvm" "libvirtd"];
    shell = pkgs.zsh;
  };

  system.stateVersion = "25.11";
}
