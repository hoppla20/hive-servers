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
    grub.enable = helpers.mkEnableOption cfg.boot.enable;
  };

  config = l.mkIf (cfg.enable && cfg.boot.enable) {
    boot.loader = {
      efi.canTouchEfiVariables = l.mkDefault true;
      grub = l.mkIf cfg.boot.grub.enable {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = l.mkDefault false;
        device = "nodev";
      };
    };
  };
}
