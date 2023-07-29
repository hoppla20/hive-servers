{
  inputs,
  cell,
  localLib,
}: renamer: moduleName: {
  lib,
  config,
  options,
  ...
}: let
  l = lib // builtins;
  inherit (lib) types;
  inherit (localLib) helpers;

  cfg = config.bee.modules.${moduleName};
in {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
  ];

  options = {
    diskSize = l.mkOption {
      type = types.ints.unsigned;
      default = 10240;
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
  };

  config = {
    formatConfigs.vm-bootloader = {config, ...}: {
      virtualisation = {
        cores = 4;
        memorySize = 4096;
        diskSize = cfg.diskSize;
        useEFIBoot = cfg.useEFIBoot;
        graphics = !cfg.headless;
        resolution = cfg.resolution;
        qemu = {
          guestAgent.enable = true;
        };
      };
    };
  };
}
