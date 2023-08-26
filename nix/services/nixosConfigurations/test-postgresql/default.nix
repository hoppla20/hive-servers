{
  inputs,
  cell,
  config,
}: {
  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  imports = [
    cell.nixosModules.postgresql
    inputs.cells.nixos.nixosModules.users
    inputs.cells.nixos.nixosProfiles.test
  ];

  hoppla = {
    nixos = {
      core.hostName = "test-postgresql";
      users.vincentcui.enable = true;
      test = {
        nixos-generators = {
          cores = 2;
          memory = 2048;
          forwardPorts = [
            {
              host.port = 5432;
              guest.port = 5432;
            }
          ];
        };
      };
    };

    services.postgresql = {
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
    defaultSopsFile = ../../__secrets/test/default.sops.yaml;
    secrets = {
      "services/nextcloud/dbpass" = {
        mode = "0400";
        owner = "postgres";
        group = "postgres";
        restartUnits = ["postgresql-ensure-users.service"];
      };
    };
  };
}
