{
  inputs,
  cell,
}: {
  imports =
    # users
    builtins.attrValues inputs.nixosModules.users
    # test
    ++ builtins.attrValues inputs.nixosModules.test
    # postgresql
    ++ [cell.nixosProfiles.postgresql-test];

  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  hoppla = {
    core.hostName = "postgresql";
    users.vincentcui.enable = true;
    test = {
      nixos-generators = {
        enable = true;
        cores = 2;
        memory = 2048;
        forwardPorts = [
          {
            proto = "tcp";
            host.port = 5432;
            guest.port = 5432;
          }
        ];
      };
    };
  };
}
