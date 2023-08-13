{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.nixpkgs) lib;
in {
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
    age = {
      generateKey = lib.mkDefault false;
      keyFile = lib.mkDefault null;
      sshKeyPaths = lib.mkDefault [];
    };
    gnupg = {
      home = lib.mkDefault null;
      sshKeyPaths = lib.mkDefault [];
    };
  };
}
