{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.localLib) helpers;
  l = inputs.nixpkgs.lib // builtins;

  cfg = config.hoppla.core;
in {
  options.hoppla.core.boot = {
    enable = helpers.mkEnableOption cfg.enable;
    grub = {
      enable = helpers.mkEnableOption cfg.boot.enable;
      efi = helpers.mkEnableOption true;
      device = l.mkOption {
        type = l.types.str;
        default =
          if cfg.boot.grub.efi
          then "nodev"
          else "/dev/disk/by-label/BOOT";
      };
    };
  };

  config = l.mkIf (cfg.enable && cfg.boot.enable) {
    boot.loader = {
      efi.canTouchEfiVariables = l.mkDefault true;
      grub = l.mkIf cfg.boot.grub.enable {
        enable = true;
        efiSupport = cfg.boot.grub.efi;
        efiInstallAsRemovable = l.mkDefault false;
        inherit (cfg.boot.grub) device;
      };
    };
  };
}
