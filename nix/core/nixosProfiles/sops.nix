{
  inputs,
  cell,
  config,
  options,
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = builtins.attrValues {
    inherit
      (inputs.nixpkgs)
      sops
      age
      ssh-to-age
      ;
  };

  sops = {
    age.sshKeyPaths = inputs.nixpkgs.lib.mkDefault ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
