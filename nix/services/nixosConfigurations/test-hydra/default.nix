{
  inputs,
  cell,
}: {
  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  imports = [
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
            writableStoreUseTmpfs = false;
          };
        };
      };
    };
  };

  nix = {
    settings.allowed-users = ["hydra"];
    buildMachines = [
      {
        hostName = "localhost";
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 4;
      }
    ];
  };

  services.hydra = {
    enable = true;
    port = 3000;
    hydraURL = "localhost:3000";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    buildMachinesFiles = ["/etc/nix/machines"];
  };

  networking.firewall.allowedTCPPorts = [3000];
}
