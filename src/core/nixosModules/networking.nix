{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) types;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;

  cfg = config.hoppla.core;
in {
  options.hoppla.core.networking = {
    enable = helpers.mkEnableOption cfg.enable;
    timeServers =
      options.networking.timeServers
      // {
        default = [
          "0.de.pool.ntp.org"
          "1.de.pool.ntp.org"
          "2.de.pool.ntp.org"
          "3.de.pool.ntp.org"
        ];
      };

    hostId = lib.mkOption {
      type = types.str;
      default = builtins.substring 0 8 (builtins.hashString "md5" cfg.hostName);
    };
  };

  config = l.mkIf (cfg.enable && cfg.networking.enable) {
    networking = {
      networkmanager.enable = true;
      inherit (cfg.networking) hostId timeServers;
    };
  };
}
