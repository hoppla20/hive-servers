{
  inputs,
  cell,
}: {
  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  imports = [
    cell.nixosModules.nextcloud
    inputs.cells.nixos.nixosModules.users
    inputs.cells.nixos.nixosProfiles.test
  ];

  hoppla = {
    nixos = {
      core.hostName = "test-nextcloud";
      users.vincentcui.enable = true;
      test = {
        nixos-generators = {
          virtualisation = {
            cores = 2;
            memorySize = 2048;
            graphics = false;
            forwardPorts = [
              {
                host.port = 8080;
                guest.port = 80;
              }
            ];
          };
        };
      };
    };

    services.nextcloud = {
      hostName = "nextcloud";
      adminpassFile = "/run/secrets/services/nextcloud/adminpass";
      database = {
        type = "pgsql";
        local = true;
        name = "nextcloud";
        user = "nextcloud";
      };
      extraHostNames = ["localhost:8080"];
    };
  };

  sops = {
    defaultSopsFile = ../../__secrets/test/default.sops.yaml;
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
}
