{
  inputs,
  cell,
}: {
  lib,
  config,
  ...
}: {
  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub.efiInstallAsRemovable = true;
  };
}
