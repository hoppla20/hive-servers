{
  inputs,
  cell,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) types;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;
in {
  options = {
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

  config = {
    services.nextcloud = {
      enable = true;
      inherit (selfCfg) hostName;
      database.createLocally = selfCfg.database.local;
      webfinger = true;
      config = {
        inherit (selfCfg) adminpassFile trustedProxies;
        adminuser = "admin";
        dbtype = selfCfg.database.type;
        dbhost = selfCfg.database.host;
        dbport = selfCfg.database.port;
        dbname = selfCfg.database.name;
        dbuser = selfCfg.database.user;
        dbpassFile = selfCfg.database.passFile;
        extraTrustedDomains = selfCfg.extraHostNames;
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    environment.systemPackages = [
      inputs.nixpkgs.postgresql
    ];
  };
}
