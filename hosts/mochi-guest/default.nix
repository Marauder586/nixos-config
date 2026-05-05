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
  # spice-vdagent is X11-only (it shells XRandR), so on a Wayland GNOME
  # session it has to attach to XWayland's :0. graphical-session.target
  # fires before XWayland is up, so without ExecStartPre the agent connects
  # too early, exits 0, and never retries — auto-resize is dead until you
  # `systemctl --user start spice-vdagent` by hand. Block on `xset q` until
  # XWayland answers, then exec the agent.
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;
  systemd.user.services.spice-vdagent = {
    description = "SPICE VD agent";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    environment.DISPLAY = ":0";
    serviceConfig = {
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in $(seq 1 60); do ${pkgs.xorg.xset}/bin/xset q >/dev/null 2>&1 && exit 0; sleep 1; done; exit 1'";
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
      Restart = "on-failure";
      RestartSec = 2;
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

  # Distinct theme so guest VM is visually distinguishable from mochi host.
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
  stylix.image = ../../everforest.jpg;

  # ── kind test cluster (kingdom.test → localhost) ──────────
  # Port-forward ingress-nginx: kubectl port-forward -n clowder-test
  #   svc/clowder-ingress-nginx-controller 8080:80 8443:443
  networking.extraHosts = ''
    127.0.0.1 forgejo.kingdom.test
    127.0.0.1 keycloak.kingdom.test
    127.0.0.1 lldap.kingdom.test
    127.0.0.1 actual.kingdom.test
  '';

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
