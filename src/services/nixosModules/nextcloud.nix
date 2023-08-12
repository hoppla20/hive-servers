{
  inputs,
  cell,
}: {
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  inherit (lib) types;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;

  cfg = config.hoppla.services.nextcloud;
in {
  options.hoppla.services.nextcloud = {
    enable = helpers.mkEnableOption false;

    hostName = l.mkOption {
      type = types.str;
    };
    adminpassFile = l.mkOption {
      type = types.str;
    };

    database = {
      local = helpers.mkEnableOption false;
      type = l.mkOption {
        type = types.enum ["sqlite" "pgsql" "mysql"];
        default = "sqlite";
      };
    };
  };

  config = l.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      inherit (cfg) hostName;
      database.createLocally = cfg.database.local;
      config = {
        inherit (cfg) adminpassFile;
        adminuser = "admin";
        dbtype = cfg.database.type;
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
