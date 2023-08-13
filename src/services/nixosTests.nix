{
  inputs,
  cell,
}: let
  tests = inputs.haumea.lib.load {
    src = ./nixosTests;
    inputs = {inherit inputs cell;};
  };
  nixos-lib = import (inputs.nixpkgs.path + "/nixos/lib") {};
in
  inputs.nixpkgs.lib.mapAttrs (_: test:
    nixos-lib.runTest {
      imports = [test];
      hostPkgs = inputs.nixpkgs;
    })
  tests
