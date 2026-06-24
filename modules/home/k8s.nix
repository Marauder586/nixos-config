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
      skopeo
      kubectl
      k9s
      kubernetes-helm
    ];
  };
}
