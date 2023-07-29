{
  inputs,
  cell,
}: renamer: moduleName: {
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types;

  cfg = config.bee.modules.${moduleName};
in {
  options = {
    hostName = lib.mkOption {
      type = types.str;
    };
  };

  config = {
    networking.hostName = cfg.hostName;

    console = {
      keyMap = lib.mkDefault "us";
      useXkbConfig = true;
    };

    time.timeZone = lib.mkDefault "Europe/Berlin";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = map (l: "${l}/UTF-8") [
        "C.UTF-8"
        "en_US.UTF-8"
        "de_DE.UTF-8"
      ];
    };

    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;

    documentation = {
      man.enable = true;
      doc.enable = false;
    };

    system.stateVersion = lib.mkDefault "23.05";

    # defaults to pass checks
    fileSystems."/" = lib.mkDefault {
      label = "nixos";
      fsType = "ext4";
    };
  };
}
