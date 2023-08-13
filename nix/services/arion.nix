{
  inputs,
  cell,
}: let
  configurations = inputs.haumea.lib.load {
    src = ./arion;
    inputs = {inherit inputs cell;};
  };
in
  inputs.nixpkgs.lib.mapAttrs (_: inputs.std.lib.dev.mkArion) configurations
