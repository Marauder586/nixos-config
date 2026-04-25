# Hyprland Wayland compositor, Alacritty terminal, Firefox (with extensions),
# clipboard tools, and Stylix theming targets.
# Controlled by: features.hyprland
{ pkgs, lib, inputs, features, ... }:
{
  config = lib.mkIf features.hyprland {
    # ── Window manager ────────────────────────────────────────
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "Alt_L";
        bind = [
          "$mod, ENTER, exec, alacritty"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let ws = i + 1; in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        ));
      };
    };

    # ── Terminal ──────────────────────────────────────────────
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        font.size = 12;
        scrolling.multiplier = 5;
        selection.save_to_clipboard = true;
      };
    };

    # ── Browser ───────────────────────────────────────────────
    programs.firefox = {
      enable = true;
      profiles.default = {
        id        = 0;
        name      = "default";
        isDefault = true;
        settings = {
          "browser.search.defaultenginename" = "ddg";
          "browser.search.order.1"           = "ddg";
        };
        search = {
          force   = true;
          default = "ddg";
          order   = [ "ddg" "google" ];
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params   = [
                  { name = "type";  value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls           = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              icon           = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@nw" ];
            };
            "bing".metaData.hidden      = true;
            "google".metaData.alias     = "@g";
          };
        };
        extensions = {
          force    = true;
          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            bitwarden
            privacy-badger
            ublock-origin
          ];
        };
      };
    };

    # ── DPI / cursor (4K monitor) ─────────────────────────────
    xresources.properties = {
      "Xcursor.size" = 16;
      "Xft.dpi"      = 172;
    };

    # ── Clipboard ─────────────────────────────────────────────
    home.packages = with pkgs; [
      wl-clipboard
      xclip
    ];

    # ── Stylix theming targets ────────────────────────────────
    stylix.autoEnable = true;
    stylix.targets.firefox = {
      enable           = true;
      colorTheme.enable = true;
      profileNames     = [ "default" ];
    };
    stylix.targets.zellij.enable = true;
  };
}
