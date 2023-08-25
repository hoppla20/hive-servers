{
  inputs,
  flake,
}: {
  core = flake.nixosConfigurations.nixos-test-core.config.hoppla;
}
