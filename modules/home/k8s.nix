# Kubernetes utilities.
# Controlled by: features.k8s-util
{
  pkgs,
  lib,
  features,
  ...
}: {
  config = lib.mkIf features."k8s-util" {
    home.packages = with pkgs; [
      kubectl
      k9s
    ];
  };
}
