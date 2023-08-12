{
  inputs,
  cell,
}: {
  core = {
    imports =
      # core
      builtins.attrValues inputs.nixosModules.core
      ++ builtins.attrValues inputs.nixosProfiles.core
      # users
      ++ builtins.attrValues inputs.nixosModules.users
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
        enable = true;
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
