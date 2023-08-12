{
  inputs,
  cell,
}: _: {
  imports = [inputs.sops-nix.nixosModules.sops];
}
