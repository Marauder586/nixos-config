# PipeWire audio stack.
# Controlled by: features.audio
{ lib, features, ... }:
{
  config = lib.mkIf features.audio {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
