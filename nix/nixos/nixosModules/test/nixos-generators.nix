{
  inputs,
  cell,
  config,
  options,
  targetCfg,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) types;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;
in {
  imports = [inputs.nixos-generators.nixosModules.all-formats];

  options = {
    enable = helpers.mkEnableOption targetCfg.enable;

    qemuGuestAgent = helpers.mkEnableOption true;
    virtualisation = l.mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = let
    shared = {
      virtualisation =
        selfCfg.virtualisation
        // {
          qemu.guestAgent.enable = selfCfg.qemuGuestAgent;
        };
    };
  in {
    formatConfigs = {
      vm = {config, ...}: shared // {};
      vm-bootloader = {config, ...}: shared // {};
      qcow = {config, ...}: {
        services.qemuGuest.enable = selfCfg.qemuGuestAgent;
      };
    };
  };
}
