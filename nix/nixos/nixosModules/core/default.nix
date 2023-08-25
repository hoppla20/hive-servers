{
  inputs,
  config,
  targetCfg,
}: let
  inherit (inputs.nixpkgs.lib) types;
  l = inputs.nixpkgs.lib // builtins;
in {
  options = {
    hostName = l.mkOption {
      type = types.str;
    };
  };

  config = {
    networking.hostName = targetCfg.hostName;

    console = {
      keyMap = l.mkDefault "us";
      useXkbConfig = true;
    };

    time.timeZone = l.mkDefault "Europe/Amsterdam";
    i18n = {
      defaultLocale = "C.UTF-8";
      supportedLocales = map (l: "${l}/UTF-8") [
        config.i18n.defaultLocale
        "en_US.UTF-8"
        "de_DE.UTF-8"
      ];
    };

    documentation = {
      doc.enable = false;
      man.enable = true;
    };

    system.stateVersion = l.mkDefault "23.05";
  };
}
