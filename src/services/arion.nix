{
  inputs,
  cell,
}: let
  configurations = inputs.localLib.helpers.load {
    inherit inputs cell;
    src = ./arion;
  };
in
  inputs.nixpkgs.lib.mapAttrs (_: inputs.std.lib.dev.mkArion) configurations
