{
  inputs,
  cell,
}: moduleName: {
  lib,
  config,
  ...
}: let
  l = lib // builtins;
  helpers = inputs.localLib.helpers;

  cfg = config.bee.modules.${moduleName};
in {
  options = {
    grub = {
      enable = helpers.mkEnableOption cfg.enable;
      vmConfig = helpers.mkEnableOption false;
    };
  };

  config = {
    boot.loader = {
      efi.canTouchEfiVariables = !cfg.grub.vmConfig;
      grub = l.mkIf cfg.grub.enable {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = cfg.grub.vmConfig;
        device = "nodev";
      };
    };
  };
}
