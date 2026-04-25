# KVM / QEMU / libvirt virtual machine host support.
# Also adds the QEMU package to system packages for the firmware symlink.
# Controlled by: features.virtualization
{ pkgs, lib, features, ... }:
{
  config = lib.mkIf features.virtualization {
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;  # virtual TPM — required by Windows 11 VMs
    };
    virtualisation.spiceUSBRedirection.enable = true;

    # Symlink QEMU firmware so libvirt can find it
    systemd.tmpfiles.rules = [
      "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
    ];

    environment.systemPackages = [ pkgs.qemu ];
  };
}
