{
  inputs,
  cell,
}: {
  imports =
    # users
    builtins.attrValues inputs.nixosModules.users
    # test
    ++ builtins.attrValues inputs.nixosModules.test
    # nextcloud
    ++ [cell.nixosProfiles.nextcloud-test];

  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
  };

  hoppla = {
    core.hostName = "nextcloud";
    users.vincentcui.enable = true;
    test = {
      enable = true;
      vm = {
        cores = 4;
        memory = 4096;
        forwardPorts = [
          {
            proto = "tcp";
            host.port = 8080;
            guest.port = 80;
          }
        ];
      };
    };
    services.nextcloud = {
      database = {
        local = true;
      };
      extraHostNames = ["localhost:8080"];
      trustedProxies = ["::1"];
    };
  };
}
