{
  inputs,
  cell,
}: {
  all = {
    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
      home = inputs.home-manager;

      extraModules = builtins.attrValues inputs.nixosModules;
      extraProfiles = builtins.attrValues inputs.nixosProfiles;
    };
  };
}
