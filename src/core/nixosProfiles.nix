{ inputs
, cell
,
}:
inputs.localLib.helpers.load {
  inherit inputs cell;
  src = ./nixosProfiles;
}
