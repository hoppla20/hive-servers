{
  inputs,
  flake,
}: let
  inherit (flake) nixosConfigurations;
in {
  core = nixosConfigurations.nixos-test-core.config.hoppla;
  postgresql = nixosConfigurations.services-test-postgresql.config.hoppla;
  nextcloud = nixosConfigurations.services-test-nextcloud.config.hoppla;
}
