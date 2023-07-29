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
      };

      extraModules = builtins.attrValues inputs.nixosModules;
      extraProfiles = builtins.attrValues inputs.nixosProfiles;
    };
  };
}
