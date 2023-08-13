{
  inputs,
  cell,
}: {
  core = {
    imports =
      # users
      builtins.attrValues inputs.nixosModules.users
      # test
      ++ builtins.attrValues cell.nixosModules
      ++ builtins.attrValues cell.nixosProfiles;

    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
      home = inputs.home-manager;
    };

    hoppla = {
      core = {
        hostName = "test";
      };
      users.vincentcui.enable = true;
      test = {
        enable = true;
        vm.memory = 2048;
      };
    };
  };
}
