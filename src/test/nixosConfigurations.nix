{
  inputs,
  cell,
}: {
  all = {
    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
      home = inputs.home-manager;

      profiles = [
        "core-core"
        "core-utils"
        "core-nix"
        "core-zsh"
      ];

      modules = {
        core-core = {
          enable = true;
          hostName = "test";
        };
        core-boot = {
          enable = true;
          grub = {
            enable = true;
            vmConfig = true;
          };
        };
        core-substituters = {
          enable = true;
          # substituters = [
          #   {url = "..."; key = "...";}
          # ];
        };
        #test-testVm = {
        #  enable = true;
        #};
      };

      extraModules = [
        inputs.nixosModules.core-core
        inputs.nixosModules.core-boot
        inputs.nixosModules.core-networking
        inputs.nixosModules.core-substituters
      ];
      extraProfiles = [
        inputs.nixosProfiles.core-utils
        inputs.nixosProfiles.core-nix
        inputs.nixosProfiles.core-zsh
      ];
    };
  };
}
