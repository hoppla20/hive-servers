{
  inputs,
  cell,
}:
inputs.localLib.helpers.loadModules {
  inherit inputs cell;
  src = ./nixosModules;
}
