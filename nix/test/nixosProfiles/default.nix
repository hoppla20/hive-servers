{
  inputs,
  cell,
  config,
  option,
}: {
  imports =
    # core
    builtins.attrValues inputs.nixosModules.core
    ++ builtins.attrValues inputs.nixosProfiles.core;

  hoppla = {
    core = {
      enable = true;
      vm.enable = true;
      ssh.enable = true;
    };
  };

  sops.age = {
    sshKeyPaths = [];
    keyFile = "/etc/sops-nix/age.key";
  };
  environment.etc = {
    "sops-nix/age.key".source = ./__secrets/age.key;
    "sops-nix/age.pub".source = ./__secrets/age.pub;
  };
}
