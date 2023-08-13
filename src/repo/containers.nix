{inputs}: let
  repoUrl = "registry.vincentcui.de:443/server/hive-servers";
in
  inputs.nixpkgs.lib.mapAttrs
  (
    name: target: let
      inherit (target) passthru;
      target' = builtins.removeAttrs target ["passthru"];
    in
      inputs.n2c.packages.nix2container.buildImage target' // passthru
  )
  {
    hello-world = {
      name = "hello-world";
      config = {
        entrypoint = ["${inputs.nixpkgs.hello}/bin/hello"];
      };
      passthru = {
        image = {
          repo = "${repoUrl}/hello-world";
          tags = ["latest"];
        };
      };
    };
  }
