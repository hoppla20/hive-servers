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

    database = l.mkOption {
      type = types.submodule ({
        name,
        config,
        ...
      }: let
        mysqlLocal = config.local && config.type == "mysql";
        pgsqlLocal = config.local && config.type == "pgsql";
      in {
        options = {
          local = helpers.mkEnableOption false;
          type = l.mkOption {
            type = types.enum ["sqlite" "pgsql" "mysql"];
            default = "sqlite";
          };
          host = helpers.mkNullOrStr (
            if pgsqlLocal
            then "/run/postgresql"
            else if mysqlLocal
            then "localhost:/run/mysqld/mysqld.sock"
            else "localhost"
          );
          port = helpers.mkNullOrInt null;
          name = helpers.mkNullOrStr null;
          user = helpers.mkNullOrStr null;
          passFile = helpers.mkNullOrStr null;
        };
      });
    };

    extraHostNames = l.mkOption {
      type = types.listOf types.str;
      default = [];
    };
    trustedProxies = l.mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = l.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      inherit (cfg) hostName;
      database.createLocally = cfg.database.local;
      webfinger = true;
      config = {
        inherit (cfg) adminpassFile trustedProxies;
        adminuser = "admin";
        dbtype = cfg.database.type;
        dbhost = cfg.database.host;
        dbport = cfg.database.port;
        dbname = cfg.database.name;
        dbuser = cfg.database.user;
        dbpassFile = cfg.database.passFile;
        extraTrustedDomains = cfg.extraHostNames;
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    environment.systemPackages = [
      inputs.nixpkgs.postgresql
    ];
  };
}
