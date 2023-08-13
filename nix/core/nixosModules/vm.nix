{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;

  cfg = config.hoppla.core;
in {
  options.hoppla.core.vm = {
    enable = helpers.mkEnableOption cfg.enable;
  };

  config = l.mkIf cfg.vm.enable (l.mkMerge [
    {
      services.qemuGuest.enable = true;
      boot.loader = {
        efi.canTouchEfiVariables = false;
        grub.efiInstallAsRemovable = cfg.boot.grub.efi;
      };
    }
    (l.mkIf cfg.boot.grub.efi {
      fileSystems."/boot" = {
        label = "ESP";
        fsType = "vfat";
      };
    })
  ]);
}
