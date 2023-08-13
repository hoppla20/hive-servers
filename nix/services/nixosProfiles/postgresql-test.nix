{
  inputs,
  cell,
  config,
  options,
}: {
  imports =
    builtins.attrValues inputs.nixosProfiles.test
    ++ [cell.nixosModules.postgresql];

  hoppla = {
    services.postgresql = {
      enable = true;
      port = 5432;
      authentication = [
        {
          database = "all";
          user = "all";
          address = "10.0.2.0/24";
          auth-method = "scram-sha-256";
        }
      ];
      ensureUsers = [
        {
          name = "test";
          createDb = true;
          createUserDb = true;
          passwordFile = "/run/secrets/services/nextcloud/dbpass";
        }
      ];
    };
  };

  sops = {
    defaultSopsFile = ./__secrets/test/default.sops.yaml;
    secrets = {
      "services/nextcloud/dbpass" = {
        mode = "0400";
        owner = config.users.users.postgres.name;
        inherit (config.users.users.postgres) group;
        restartUnits = ["postgresql-ensure-users"];
      };
    };
  };
}
