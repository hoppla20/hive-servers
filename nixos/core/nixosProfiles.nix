{
  inputs,
  cell,
}:
inputs.localLibs.helpers.load {
  inherit inputs cell;
  src = ./nixosProfiles;
}
