{
  inputs,
  cell,
  config,
  options,
}: let
  l = inputs.nixpkgs.lib // builtins;
in {
  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      efiInstallAsRemovable = config.hoppla.core.boot.grub.efi;
      device = l.mkForce (
        if config.hoppla.core.boot.grub.efi
        then "nodev"
        else "/dev/vda"
      );
    };
  };
}
