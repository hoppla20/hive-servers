{
  inputs,
  cell,
}: {
  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  imports = [
    cell.nixosModules.hydra
    inputs.cells.nixos.nixosModules.users
    inputs.cells.nixos.nixosProfiles.test
  ];

  hoppla = {
    nixos = {
      core.hostName = "test-hydra";
      users.vincentcui.enable = true;
      test = {
        nixos-generators = {
          virtualisation = {
            cores = 4;
            memorySize = 8192;
            graphics = false;
            forwardPorts = [
              {
                host.port = 3000;
                guest.port = 3000;
              }
            ];
            useNixStoreImage = true;
            writableStore = true;
          };
        };
      };
    };
    services.hydra = {
      ensureUsers = [
        {
          name = "vincent.cui";
          passwordFile = "/run/secrets/services/hydra/users/vincent.cui/password";
          roles = ["admin"];
        }
      ];
      config = {
        enable = true;
        port = 3000;
        hydraURL = "localhost:3000";
        notificationSender = "hydra@localhost";
        useSubstitutes = true;
      };
    };
  };

  sops = {
    defaultSopsFile = ../../__secrets/test/default.sops.yaml;
    secrets = {
      "services/hydra/users/vincent.cui/password" = {
        owner = "hydra";
        group = "hydra";
        mode = "0400";
        restartUnits = ["hydra-ensure-users.service"];
      };
    };
  };
}
