{
  inputs,
  cell,
  config,
}: {
  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  imports = with inputs.cells; [
    cell.nixosModules.postgresql
    nixos.nixosModules.users
    nixos.nixosProfiles.test
  ];

  hoppla = {
    nixos = {
      core.hostName = "test-postgresql";
      users."vincent.cui".enable = true;
      test = {
        nixos-generators = {
          virtualisation = {
            cores = 2;
            memorySize = 2048;
            graphics = false;
            forwardPorts = [
              {
                host.port = 5432;
                guest.port = 5432;
              }
            ];
          };
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
