{
  inputs,
  cell,
}:
inputs.haumea.lib.load {
  src = ./nixosConfigurations;
  inputs = {inherit inputs cell;};
}
