# Ollama local LLM server + Open-WebUI frontend + local STT/TTS.
#
# STT: faster-whisper (built into Open WebUI, runs on CPU — switch
#      AUDIO_STT_DEVICE to "cuda" once ROCm fully supports gfx1201/RDNA4).
# TTS: openedai-speech container (OpenAI-compatible endpoint, Kokoro backend).
#      Models are downloaded into /var/lib/openedai-speech on first start.
#
# Controlled by: features.ai
{ lib, features, pkgs-unstable, ... }:
{
  config = lib.mkIf features.ai {

    # ── Ollama ────────────────────────────────────────────────
    services.ollama = {
      enable     = true;
      package    = pkgs-unstable.ollama-vulkan;  # AMD Vulkan GPU acceleration
      loadModels = [ "qwen3.5:35b" ];
    };

    # ── Open WebUI ────────────────────────────────────────────
    services.open-webui = {
      enable = true;
      environment = {
        # STT — faster-whisper (built-in, no extra service needed)
        AUDIO_STT_ENGINE = "faster-whisper";
        AUDIO_STT_MODEL  = "distil-large-v3";
        # Use "cuda" here once ROCm 6.x fully supports gfx1201 (RDNA 4 / 9070 XT)
        AUDIO_STT_DEVICE = "cpu";

        # TTS — openedai-speech running on localhost:8000
        AUDIO_TTS_ENGINE              = "openai";
        AUDIO_TTS_OPENAI_API_BASE_URL = "http://127.0.0.1:8000/v1";
        AUDIO_TTS_OPENAI_API_KEY      = "sk-openedai";  # ignored by the server
        AUDIO_TTS_MODEL               = "kokoro";
        AUDIO_TTS_VOICE               = "af_sky";
      };
    };

    # ── openedai-speech container ─────────────────────────────
    # Persistent directory for downloaded Kokoro voice models (~500 MB)
    systemd.tmpfiles.rules = [
      "d /var/lib/openedai-speech 0755 root root -"
    ];

    virtualisation.oci-containers.containers.openedai-speech = {
      image  = "ghcr.io/matatonic/openedai-speech";
      ports  = [ "127.0.0.1:8000:8000" ];
      # Persist voice model cache across container rebuilds
      volumes = [ "/var/lib/openedai-speech:/app/voices" ];
      environment = {
        PRELOAD_MODEL = "kokoro";  # download Kokoro on startup, not on first request
      };
    };

    # Podman is the NixOS-native container runtime
    virtualisation.podman = {
      enable       = true;
      dockerCompat = true;  # lets oci-containers use the docker CLI shim
    };
    virtualisation.oci-containers.backend = "podman";
  };
}
