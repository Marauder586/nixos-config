# Kubernetes utilities.
# Controlled by: features.k8sUtil
{
  pkgs,
  lib,
  features,
  ...
}: {
  config = lib.mkIf features.k8sUtil {
    home.packages = with pkgs; [
      kubectl
      k9s
    ];
  };
}
