{
  inputs,
  targetCfg,
  selfCfg,
}: let
  inherit (inputs.localLib) helpers;
  l = inputs.nixpkgs.lib // builtins;
in {
  options = {
    enable = helpers.mkEnableOption targetCfg.enable;
    grub = {
      efi = helpers.mkEnableOption true;
      device = l.mkOption {
        type = l.types.str;
        default =
          if selfCfg.grub.efi
          then "nodev"
          else "/dev/disk/by-label/BOOT";
      };
    };
  };

  config = l.mkIf selfCfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = l.mkDefault true;
      grub = {
        enable = true;
        efiSupport = selfCfg.grub.efi;
        efiInstallAsRemovable = l.mkDefault false;
        inherit (selfCfg.grub) device;
      };
    };
  };
}
