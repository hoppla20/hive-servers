{
  inputs,
  cell,
  config,
  options,
}: let
  l = inputs.nixpkgs.lib // builtins;
in {
  boot.loader = {
    grub = {
      device = l.mkForce (
        if config.hoppla.core.boot.grub.efi
        then "nodev"
        else "/dev/vda"
      );
    };
  };
}
