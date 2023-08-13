{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  inherit (lib) types;
  l = lib // builtins;

  cfg = config.hoppla.services.postgresql;

  mkStr = l.mkOption {type = types.str;};

  authenticationSubmodule = types.submodule (_: {
    options = {
      database = mkStr;
      user = mkStr;
      address = mkStr;
      auth-method = mkStr;
      auth-options = helpers.mkNullOrStr null;
    };
  });

  userSubmodule = types.submodule ({config, ...}: {
    options = {
      name = mkStr;
      createDb = helpers.mkEnableOption false;
      createUserDb = helpers.mkEnableOption true;
      userDbName = mkStr // {default = config.name;};
      passwordFile = mkStr;
    };
  });

  authToString = {
    database,
    user,
    address,
    auth-method,
    auth-options,
  }: "host ${database} ${user} ${address} ${auth-method}${l.optionalString (auth-options != null) " ${auth-options}"}";

  createUserCommands = {
    name,
    createDb,
    createUserDb,
    userDbName,
    passwordFile,
  }: let
    psqlc = "psql --port=${toString cfg.port} -c";
  in ''
    # create user ${name}

    ${psqlc} "select usename from pg_catalog.pg_user;" -t | grep -w -q "${name}" && (
      # user exists
      ${psqlc} "alter user ${name} with encrypted password '$(cat ${passwordFile})'${l.optionalString createDb " createdb"};"
    ) || (
      # users does not exist
      ${psqlc} "create user ${name} with encrypted password '$(cat ${passwordFile})'${l.optionalString createDb " createdb"};"
    )

    ${l.optionalString createUserDb ''
      # create db ${userDbName}

      ${psqlc} "select datname from pg_catalog.pg_database;" -t | grep -w -q "${userDbName}" || (
        # db does not exist
        ${psqlc} "create database ${userDbName};"
        ${psqlc} "grant all privileges on database ${userDbName} to ${name};"
      )
    ''}
  '';
in {
  options.hoppla.services.postgresql = {
    enable = helpers.mkEnableOption false;
    port = l.mkOption {
      type = types.int;
      default = 5432;
    };
    authentication = l.mkOption {
      type = types.listOf authenticationSubmodule;
      default = [];
    };
    ensureUsers = l.mkOption {
      type = types.listOf userSubmodule;
      default = [];
    };
  };

  config = l.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      inherit (cfg) port;
      enableTCPIP = true;
      authentication = l.mkForce ''
        # Generated file; do not edit!

        # local
        local all all              peer
        host  all all 127.0.0.1/32 scram-sha-256
        host  all all              ::1/128 scram-sha-256

        # module
        ${l.concatStringsSep "\n" (l.map authToString cfg.authentication)}
      '';
    };

    systemd.services.postgresql-ensure-users = {
      description = "Ensure that PostgreSQL users are present";

      wantedBy = ["multi-user.target"];
      after = ["postgresql.service"];

      environment.PGDATA = config.services.postgresql.dataDir;
      path = [config.services.postgresql.package];

      script = ''
        ${l.concatStringsSep "\n\n" (l.map createUserCommands cfg.ensureUsers)}
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        RuntimeDirectory = "postgresql";
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
