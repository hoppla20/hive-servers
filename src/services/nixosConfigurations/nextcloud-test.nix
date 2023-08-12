{
  inputs,
  cell,
}: {
  imports =
    # core
    builtins.attrValues inputs.nixosModules.core
    ++ builtins.attrValues inputs.nixosProfiles.core
    # users
    ++ builtins.attrValues inputs.nixosModules.users
    # test
    ++ builtins.attrValues inputs.nixosModules.test
    ++ builtins.attrValues inputs.nixosProfiles.test
    # nextcloud
    ++ [cell.nixosModules.nextcloud];

  bee = {
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs;
    home = inputs.home-manager;
  };

  hoppla = {
    core = {
      enable = true;
      hostName = "nextcloud-test";
    };
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
    services = {
      nextcloud = {
        enable = true;
        hostName = "localhost:8080";
        adminpassFile = "/secrets/nextcloudAdminpass";
        database = {
          type = "pgsql";
          local = true;
        };
      };
    };
  };

  # use sops-nix in production
  system.activationScripts = {
    prepareSecrets.text = ''
      #!/usr/bin/env bash
      mkdir -p /secrets
      chown root:root /secrets
      chmod 0755 /secrets
    '';

    nextcloudAdminpass = {
      text = ''
        #!/usr/bin/env bash
        echo "admin" > /secrets/nextcloudAdminpass
        chown nextcloud:nextcloud /secrets/nextcloudAdminpass
        chmod 0400 /secrets/nextcloudAdminpass
      '';
      deps = ["prepareSecrets"];
    };
  };
}
