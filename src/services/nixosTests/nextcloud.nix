{
  inputs,
  cell,
}: let
  pkgs = inputs.nixpkgs;
  l = pkgs.lib // builtins;
in {
  name = "nextcloud";

  extraPythonPackages = p: [p.psycopg2];

  defaults = {
    virtualisation = {
      qemu.guestAgent.enable = true;
      graphics = false;
    };
  };

  nodes = {
    db = {
      config,
      options,
      ...
    }: {
      virtualisation = {
        cores = 2;
        memorySize = 2048;
      };

      imports = [cell.nixosProfiles.postgresql-test];

      hoppla = {
        core.hostName = "postgresql";
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
    };
    nextcloud = {
      config,
      options,
      ...
    }: {
      imports = [cell.nixosProfiles.nextcloud-test];

      virtualisation = {
        cores = 4;
        memorySize = 4096;
      };

      hoppla = {
        core.hostName = "nextcloud";
        services.nextcloud = {
          database = {
            host = "postgresql";
            port = 5432;
            passFile = "/run/secrets/services/nextcloud/dbpass";
          };
        };
      };
    };
  };

  testScript = let
    withRcloneEnv = pkgs.writeScript "with-rclone-env" ''
      #!${pkgs.runtimeShell}
      export RCLONE_CONFIG_NEXTCLOUD_TYPE=webdav
      export RCLONE_CONFIG_NEXTCLOUD_URL="http://nextcloud/remote.php/webdav/"
      export RCLONE_CONFIG_NEXTCLOUD_VENDOR="nextcloud"
      export RCLONE_CONFIG_NEXTCLOUD_USER="admin"
      export RCLONE_CONFIG_NEXTCLOUD_PASS="$(${pkgs.rclone}/bin/rclone obscure admin)"
      "''${@}"
    '';
    copyFile = pkgs.writeScript "copy-shared-file" ''
      #!${pkgs.runtimeShell}
      echo 'hi' | ${pkgs.rclone}/bin/rclone rcat nextcloud:test-shared-file
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
