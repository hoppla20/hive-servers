{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in {
  name = "nextcloud";

  extraPythonPackages = p: [p.psycopg2];

  defaults = {
    imports = [
      inputs.cells.nixos.nixosModules.users
      inputs.cells.nixos.nixosProfiles.test
    ];

    virtualisation = {
      cores = 2;
      memorySize = 2048;
    };

    hoppla.nixos.users."vincent.cui".enable = true;

    sops.defaultSopsFile = ../../__secrets/test/default.sops.yaml;
  };

  nodes = {
    postgresql = {
      config,
      options,
      ...
    }: {
      imports = [cell.nixosModules.postgresql];

      hoppla = {
        nixos.core.hostName = "postgresql";
        services.postgresql = {
          authentication = [
            {
              database = "all";
              user = "all";
              address = "192.168.1.0/24";
              auth-method = "scram-sha-256";
            }
          ];
          ensureUsers = l.mkForce [
            {
              name = "nextcloud";
              createDb = true;
              createUserDb = true;
              passwordFile = "/run/secrets/services/nextcloud/dbpass";
            }
          ];
        };
      };

      sops = {
        secrets = {
          "services/nextcloud/dbpass" = {
            mode = "0400";
            owner = "postgres";
            group = "postgres";
            restartUnits = ["postgresql-ensure-users.service"];
          };
        };
      };
    };

    nextcloud = {
      config,
      options,
      ...
    }: {
      imports = [cell.nixosModules.nextcloud];

      hoppla = {
        nixos.core.hostName = "nextcloud";
        services.nextcloud = {
          hostName = "nextcloud";
          extraHostNames = ["localhost:8080"];
          adminpassFile = "/run/secrets/services/nextcloud/adminpass";
          database = {
            type = "pgsql";
            host = "postgresql";
            port = 5432;
            name = "nextcloud";
            user = "nextcloud";
            passFile = "/run/secrets/services/nextcloud/dbpass";
          };
        };
      };

      sops = {
        secrets = let
          nextcloudSecret = {
            mode = "0400";
            owner = "nextcloud";
            group = "nextcloud";
            restartUnits = ["nextcloud-setup.service"];
          };
        in {
          "services/nextcloud/adminpass" = nextcloudSecret;
          "services/nextcloud/dbpass" = nextcloudSecret;
        };
      };
    };
  };

  testScript = let
    withRcloneEnv = nixpkgs.writeScript "with-rclone-env" ''
      #!${nixpkgs.runtimeShell}
      ADMIN_PASS="$(cat /run/secrets/services/nextcloud/adminpass)"
      export RCLONE_CONFIG_NEXTCLOUD_TYPE=webdav
      export RCLONE_CONFIG_NEXTCLOUD_URL="http://nextcloud/remote.php/webdav/"
      export RCLONE_CONFIG_NEXTCLOUD_VENDOR="nextcloud"
      export RCLONE_CONFIG_NEXTCLOUD_USER="admin"
      export RCLONE_CONFIG_NEXTCLOUD_PASS="$(${nixpkgs.rclone}/bin/rclone obscure "$ADMIN_PASS")"
      "''${@}"
    '';
    copyFile = nixpkgs.writeScript "copy-shared-file" ''
      #!${nixpkgs.runtimeShell}
      echo 'hi' | ${nixpkgs.rclone}/bin/rclone rcat nextcloud:test-shared-file
    '';
  in ''
    postgresql.start()
    postgresql.wait_for_unit("multi-user.target")

    nextcloud.start()
    nextcloud.wait_for_unit("multi-user.target")

    # for interactive testing
    postgresql.forward_port(guest_port=5432,host_port=5432)
    nextcloud.forward_port(guest_port=80,host_port=8080)

    nextcloud.succeed("curl -sSf http://nextcloud/login")
    nextcloud.succeed("${withRcloneEnv} ${copyFile}")
  '';
}
