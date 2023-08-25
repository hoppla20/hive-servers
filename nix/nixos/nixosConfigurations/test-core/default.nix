{
  inputs,
  cell,
}: {
  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  imports = [
    cell.nixosProfiles.test
    cell.nixosModules.users
  ];

  hoppla = {
    nixos = {
      core.hostName = "core-test";
      users.vincentcui.enable = true;
      test = {
        nixos-generators = {
          cores = 2;
          memory = 2048;
        };
      };
    };
  };
}
