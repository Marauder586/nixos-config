# Ollama local LLM server + Open-WebUI frontend.
# Uses nixpkgs-unstable for ollama-vulkan (AMD GPU acceleration).
# Controlled by: features.ai
{ lib, features, pkgs-unstable, ... }:
{
  config = lib.mkIf features.ai {
    services.ollama = {
      enable = true;
      package = pkgs-unstable.ollama-vulkan;  # AMD Vulkan GPU acceleration
      loadModels = [ "qwen3.5:35b" ];
    };
    services.open-webui.enable = true;
  };
}
