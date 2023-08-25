let
  flake = builtins.getFlake (toString ./.);
in rec {
  inherit flake;
  inherit (flake) inputs;

  l = inputs.nixpkgs.lib // builtins;
  evalNixosModules = import "${inputs.nixpkgs}/nixos/lib/eval-config.nix";

  inherit (flake.x86_64-linux.nixos) nixosModules nixosProfiles nixosConfigurations;

  testModule = module:
    module {
      config = {};
      options = {};
    };

  evaledConfigurations = l.mapAttrs (_: config:
    evalNixosModules {
      system = "x86_64-linux";
      modules = [config];
    })
  nixosConfigurations;
}
