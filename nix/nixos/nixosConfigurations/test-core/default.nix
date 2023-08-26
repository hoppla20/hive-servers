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
      users."vincent.cui".enable = true;
      test = {
        nixos-generators = {
          virtualisation = {
            cores = 2;
            memorySize = 2048;
            graphics = false;
          };
        };
      };
    };
  };
}
