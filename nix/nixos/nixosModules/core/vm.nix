{
  inputs,
  targetCfg,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;
in {
  options = {
    enable = helpers.mkEnableOption false;
  };

  config = l.mkIf selfCfg.enable {
    services.qemuGuest.enable = true;
    boot.loader = {
      efi.canTouchEfiVariables = false;
      grub.efiInstallAsRemovable = targetCfg.boot.grub.efi;
    };

    fileSystems."/" = l.mkDefault {
      label = "nixos";
      fsType = "ext4";
    };
    fileSystems."/boot" = l.mkDefault {
      label =
        if targetCfg.boot.grub.efi
        then "ESP"
        else "BOOT";
      fsType = "vfat";
    };
  };
}
