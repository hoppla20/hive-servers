{
  inputs,
  cell,
}: {
  default = {
    imports =
      # modules
      builtins.attrValues inputs.nixosModules.core
      ++ builtins.attrValues cell.nixosModules
      # profiles
      ++ builtins.attrValues inputs.nixosProfiles.core
      ++ [cell.nixosProfiles.boot];

    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
      home = inputs.home-manager;
    };

    hoppla = {
      core = {
        enable = true;
        hostName = "test";
        boot.enable = true;
      };
      test.vm = {
        memory = 2048;
      };
    };
  };
}
