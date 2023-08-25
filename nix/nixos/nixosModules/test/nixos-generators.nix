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

    cores = l.mkOption {
      type = types.ints.unsigned;
      default = 1;
    };
    memory = l.mkOption {
      type = types.ints.unsigned;
      default = 1024;
    };
    diskSize = l.mkOption {
      type = types.ints.unsigned;
      default = 1024;
    };
    useEFIBoot = helpers.mkEnableOption true;
    headless = helpers.mkEnableOption false;
    resolution = {
      x = l.mkOption {
        type = types.ints.unsigned;
        default = 1280;
      };
      y = l.mkOption {
        type = types.ints.unsigned;
        default = 800;
      };
    };
    forwardPorts = l.mkOption {
      type = types.listOf types.attrs;
      default = [];
    };
  };

  config = let
    shared = {
      virtualisation = {
        inherit (selfCfg) cores diskSize useEFIBoot resolution forwardPorts;
        memorySize = selfCfg.memory;
        graphics = !selfCfg.headless;
        qemu.guestAgent.enable = true;
      };
    };
  in {
    formatConfigs = {
      vm = {config, ...}: shared // {};
      vm-bootloader = {config, ...}: shared // {};
      qcow = {config, ...}: {
        services.qemuGuest.enable = true;
      };
    };
  };
}
