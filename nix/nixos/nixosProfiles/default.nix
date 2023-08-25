{
  inputs,
  cell,
}:
inputs.localLib.helpers.loadTargets {
  inherit inputs cell;
  block = ./.;
  type = "nixosProfiles";
}
