{
  inputs,
  cell,
}: {
  core = {
    imports =
      # users
      builtins.attrValues inputs.nixosModules.users
      # test
      ++ builtins.attrValues cell.nixosProfiles
      ++ builtins.attrValues cell.nixosModules;

    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
    };

    hoppla = {
      core = {
        hostName = "test";
      };
      users.vincentcui.enable = true;
      test.nixos-generators = {
        enable = true;
        memory = 2048;
      };
    };
  };
}
