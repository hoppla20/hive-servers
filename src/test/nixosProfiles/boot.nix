{
  inputs,
  cell,
  config,
  options,
}: {
  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub.efiInstallAsRemovable = true;
  };
}
