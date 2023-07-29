{ inputs
, cell
,
}: {
  all = {
    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
      home = inputs.home-manager;

      profiles = [ "core-core" ];

      modules = {
        core-boot.enable = true;
        core-boot.grub.vmConfig = true;
      };

      extraModules = builtins.attrValues inputs.nixosModules;
      extraProfiles = builtins.attrValues inputs.nixosProfiles;
    };
  };
}
