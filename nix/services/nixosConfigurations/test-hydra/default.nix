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
          cores = 4;
          memory = 8192;
          forwardPorts = [
            {
              host.port = 3000;
              guest.port = 3000;
            }
          ];
        };
      };
    };
  };

  services.hydra = {
    enable = true;
    port = 3000;
    hydraURL = "localhost:3000";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
  };

  networking.firewall.allowedTCPPorts = [3000];
}
