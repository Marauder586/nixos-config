# Local-first agentic coding CLI.
#
# Primary agent: opencode (https://opencode.ai) — Claude-Code-shaped TUI that
# speaks any OpenAI-compatible endpoint, MCP servers, agents/, and command/.
# Configured to talk to Ollama on the mochi host (10.0.2.2:11434/v1 from the
# guest, 127.0.0.1:11434 elsewhere) with optional fallback providers.
#
# Companions installed alongside for variety: aider, goose, crush, codex,
# plandex, mcphost. Pick whichever fits the task.
#
# Skills, sub-agents, and slash-commands are dropped into ~/.config/opencode/
# from this module's `agent/`, `command/`, and `skills/` directories.
#
# Controlled by: features.codingAgent
{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  features,
  ...
}: let
  cfg = features.codingAgent or false;

  # Ollama host endpoint. The mochi host runs Ollama on :11434; from the
  # mochi-guest QEMU/SLIRP makes the host reachable as 10.0.2.2.
  ollamaHost = features.ollamaHost or "http://10.0.2.2:11434";
  ollamaBaseURL = "${ollamaHost}/v1";

  # ComfyUI host endpoint (mochi runs this when features.comfyui is on).
  comfyuiHost = features.comfyuiHost or "http://10.0.2.2:8188";

  # Open WebUI (for reference; OpenAI API requires a key, prefer Ollama direct).
  openWebUIHost = features.openWebuiHost or "http://10.0.2.2:8080";

  defaultModel = features.codingAgentModel or "ollama/qwen2.5-coder:7b";
  smartModel = features.codingAgentSmartModel or "ollama/qwen3.5:35b";

  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    theme = "system";
    model = defaultModel;
    small_model = "ollama/llama3.1:8b";
    autoshare = false;
    autoupdate = false;

    # OpenAI-compatible providers. Ollama exposes /v1 natively; we declare
    # each model we want to surface in the picker.
    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (mochi)";
        options = {
          baseURL = ollamaBaseURL;
        };
        models = {
          "qwen2.5-coder:7b" = {
            name = "Qwen2.5-Coder 7B";
          };
          "qwen3.5:35b" = {
            name = "Qwen3.5 35B (smart)";
          };
          "llama3.1:8b" = {
            name = "Llama 3.1 8B (fast)";
          };
        };
      };
    };

    # Opencode looks up @<name> sub-agents in $XDG_CONFIG_HOME/opencode/agent/
    # and slash commands in command/. Both are populated by xdg.configFile
    # below from this module's checked-in markdown files.
    agent = {
      build = {
        model = defaultModel;
      };
      plan = {
        model = smartModel;
      };
    };

    # MCP servers — give the agent web fetch, search, browser automation,
    # filesystem, GitHub access, and the ComfyUI bridge for image / 3D work.
    mcp = {
      filesystem = {
        type = "local";
        enabled = true;
        command = [
          "${pkgs.nodejs_22}/bin/npx"
          "-y"
          "@modelcontextprotocol/server-filesystem"
          "${config.home.homeDirectory}"
        ];
      };

      fetch = {
        type = "local";
        enabled = true;
        command = [
          "${pkgs.uv}/bin/uvx"
          "mcp-server-fetch"
        ];
      };

      searxng = {
        type = "local";
        enabled = true;
        command = [
          "${pkgs.uv}/bin/uvx"
          "mcp-searxng"
        ];
        environment = {
          SEARXNG_URL = features.searxngUrl or "https://searx.be";
        };
      };

      duckduckgo = {
        type = "local";
        enabled = true;
        command = [
          "${pkgs.uv}/bin/uvx"
          "duckduckgo-mcp-server"
        ];
      };

      playwright = {
        type = "local";
        enabled = true;
        command = [
          "${pkgs-unstable.playwright-mcp}/bin/playwright-mcp"
          "--headless"
          "--isolated"
        ];
      };

      github = {
        type = "local";
        enabled = false; # set GITHUB_PERSONAL_ACCESS_TOKEN and flip on
        command = [
          "${pkgs.github-mcp-server}/bin/github-mcp-server"
          "stdio"
        ];
        environment = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "$GITHUB_PERSONAL_ACCESS_TOKEN";
        };
      };

      # ComfyUI bridge — image generation + image-to-3D. The mochi host
      # exposes ComfyUI at :8188 when features.comfyui is enabled there.
      comfyui = {
        type = "local";
        enabled = true;
        command = [
          "${pkgs.uv}/bin/uvx"
          "comfyui-mcp-server"
        ];
        environment = {
          COMFYUI_URL = comfyuiHost;
          # Where the bridge writes generated assets.
          COMFYUI_OUTPUT_DIR = "${config.home.homeDirectory}/comfy-out";
        };
      };
    };

    # Endpoints surfaced to skills / agent prompts via env in shell.
    experimental = {
      hint_endpoints = {
        ollama = ollamaBaseURL;
        comfyui = comfyuiHost;
        open_webui = openWebUIHost;
      };
    };
  };

  # Shorter aiders config — defaults the model, points it at Ollama.
  aiderConfig = ''
    # Ollama on the mochi host. aider reads OLLAMA_API_BASE for ollama/* models.
    model: ollama_chat/qwen2.5-coder:7b
    weak-model: ollama_chat/llama3.1:8b
    edit-format: diff
    auto-commits: false
    dirty-commits: false
    pretty: true
    stream: true
    suggest-shell-commands: true
    show-model-warnings: false
  '';

  gooseConfig = ''
    GOOSE_PROVIDER: openai
    GOOSE_MODEL: qwen2.5-coder:7b
    OPENAI_HOST: ${ollamaHost}
    OPENAI_BASE_PATH: v1/chat/completions
    OPENAI_API_KEY: ollama
  '';

  crushConfig = {
    "$schema" = "https://charm.land/crush.json";
    providers = {
      ollama = {
        type = "openai";
        base_url = ollamaBaseURL;
        api_key = "ollama";
        name = "Ollama (mochi)";
        models = [
          {
            id = "qwen2.5-coder:7b";
            name = "Qwen2.5 Coder 7B";
            context_window = 32768;
            default_max_tokens = 4096;
          }
          {
            id = "qwen3.5:35b";
            name = "Qwen3.5 35B";
            context_window = 32768;
            default_max_tokens = 4096;
          }
        ];
      };
    };
  };

  shellEnv = {
    # Aider, llm, codex CLI all honour these.
    OPENAI_API_BASE = ollamaBaseURL;
    OPENAI_BASE_URL = ollamaBaseURL;
    OPENAI_API_KEY = "ollama";
    OLLAMA_API_BASE = ollamaHost;
    OLLAMA_HOST = ollamaHost;
    # Hand-off endpoints for skills / scripts.
    COMFYUI_URL = comfyuiHost;
    OPEN_WEBUI_URL = openWebUIHost;
  };
in {
  config = lib.mkIf cfg {
    home.packages = with pkgs; [
      # ── Agentic CLIs ─────────────────────────────────────────
      pkgs-unstable.opencode # primary
      aider-chat
      goose-cli
      crush
      plandex
      mcphost # MCP debugger / runner

      # ── MCP server runtimes ──────────────────────────────────
      nodejs_22 # @modelcontextprotocol/server-* via npx
      uv # `uvx` for python MCP servers (mcp-server-fetch, mcp-searxng…)
      pkgs-unstable.playwright-mcp
      github-mcp-server
      mcp-proxy

      # ── Coding workhorses ───────────────────────────────────
      ripgrep
      fd
      fzf
      jq
      yq-go
      dasel
      tree
      bat
      eza
      zoxide
      delta
      hyperfine
      tokei
      gh
      just
      pandoc
      glow

      # Runtimes the MCP servers themselves need (uvx for python servers,
      # npx for JS servers). Project-specific toolchains belong in per-repo
      # devShells, not the user profile.
      python3
      nodejs_22
      gnumake

      # Linters / formatters
      shellcheck
      shfmt
      nodePackages.prettier
      ruff
      black
      mypy
      alejandra # nix formatter

      # ── Web research ────────────────────────────────────────
      curl
      wget
      httpie
      xh
      lynx
      w3m
      monolith # archive a page to a single .html
      yt-dlp
      pup
      htmlq
      python313Packages.trafilatura # readability extraction
      python313Packages.ddgs # DuckDuckGo CLI / library

      # ── 3D modeling ─────────────────────────────────────────
      openscad-unstable # parametric, text-driven (LLM-friendly)
      freecad # python-scriptable CAD
      blender # bpy scripting + huge plugin ecosystem
      meshlab # mesh repair / decimation
      f3d # quick 3D viewer
      assimp # `assimp` cli — convert between 3D formats
      super-slicer
    ];

    home.sessionVariables = shellEnv;

    # ── opencode ────────────────────────────────────────────────
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON opencodeConfig;
    xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;

    # Sub-agents (invoked with @<name>) and slash commands.
    xdg.configFile."opencode/agent" = {
      source = ./agent;
      recursive = true;
    };
    xdg.configFile."opencode/command" = {
      source = ./command;
      recursive = true;
    };

    # Free-form skill notes — referenced by the agents and indexed by AGENTS.md.
    xdg.configFile."opencode/skills" = {
      source = ./skills;
      recursive = true;
    };

    # ── aider ───────────────────────────────────────────────────
    home.file.".aider.conf.yml".text = aiderConfig;

    # ── goose ───────────────────────────────────────────────────
    xdg.configFile."goose/config.yaml".text = gooseConfig;

    # ── crush ───────────────────────────────────────────────────
    xdg.configFile."crush/crush.json".text = builtins.toJSON crushConfig;

    # Working directory for image/3D pipeline outputs.
    home.file."comfy-out/.keep".text = "";
  };
}
