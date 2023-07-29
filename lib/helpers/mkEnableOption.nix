{ inputs }: default:
let
  l = inputs.nixpkgs.lib // builtins;
in
l.mkOption {
  inherit default;
  type = l.types.bool;
}
