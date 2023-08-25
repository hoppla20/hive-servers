{
  inputs,
  cellCfg,
}: let
  l = inputs.nixpkgs.lib // builtins;
in {
  boot.loader = {
    grub = {
      device = l.mkForce (
        if cellCfg.core.boot.grub.efi
        then "nodev"
        else "/dev/vda"
      );
    };
  };
}
