{
  inputs,
  cell,
}: let
  nixos-lib = import (inputs.nixpkgs.path + "/nixos/lib") {};
in
  builtins.mapAttrs
  (_: test:
    nixos-lib.runTest {
      imports = [test];
      hostPkgs = inputs.nixpkgs;
    })
  (inputs.localLib.helpers.loadTargets {
    inherit inputs cell;
    block = ./.;
    type = "default";
  })
