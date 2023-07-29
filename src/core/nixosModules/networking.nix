{
  inputs,
  cell,
}: renamer: moduleName: {
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  inherit (lib) types;
in {
  options = {
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
      default = builtins.substring 0 8 (builtins.hashString "md5" config.bee.modules.${renamer "core"}.hostName);
    };
  };

  config = {};
}
