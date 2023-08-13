{
  inputs,
  cell,
}: let
  pkgs = inputs.nixpkgs;
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
      pkgs,
      config,
      ...
    }: {
      virtualisation = {
        cores = 2;
        memorySize = 2048;
      };

      imports = builtins.attrValues inputs.nixosProfiles.test;

      hoppla = {
        core.hostName = "db";
      };

      services.postgresql = {
        enable = true;
        enableTCPIP = true;
        port = 5432;
        authentication = ''
          #type database dbuser address        auth-method
          host  all      all    10.0.2.0/24    md5
          host  all      all    192.168.1.0/24 md5
        '';
        initialScript = pkgs.writeText "db-init" ''
          set password_encryption = 'md5';
          create role nextcloud with login password 'nextcloud' createdb;
          create database nextcloud;
          grant all privileges on database nextcloud to nextcloud;
        '';
      };

      networking.firewall.allowedTCPPorts = [5432];
    };
    nextcloud = {
      pkgs,
      config,
      ...
    }: {
      imports = [cell.nixosProfiles.nextcloud-test];

      virtualisation = {
        cores = 4;
        memorySize = 4096;
      };

      hoppla = {
        services.nextcloud = {
          database = {
            host = "db";
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
    db.start()
    db.wait_for_unit("multi-user.target")

    nextcloud.start()
    nextcloud.wait_for_unit("multi-user.target")

    # for interactive testing
    db.forward_port(guest_port=5432,host_port=5432)
    nextcloud.forward_port(guest_port=80,host_port=8080)

    nextcloud.succeed("curl -sSf http://nextcloud/login")
    nextcloud.succeed("${withRcloneEnv} ${copyFile}")
  '';
}
