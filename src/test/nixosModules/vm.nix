{
  inputs,
  cell,
  localLib,
}: {
  lib,
  config,
  options,
  ...
}: let
  l = lib // builtins;
  inherit (lib) types;
  inherit (localLib) helpers;

  cfg = config.hoppla.test.vm;
in {
  imports = [inputs.nixos-generators.nixosModules.all-formats];

  options.hoppla.test.vm = {
    enable = helpers.mkEnableOption false;
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

  config = l.mkMerge [
    (
      let
        shared = {
          virtualisation = {
            inherit (cfg) cores diskSize useEFIBoot resolution;
            memorySize = cfg.memory;
            graphics = !cfg.headless;
            qemu = {
              guestAgent.enable = true;
            };
          };
        };
      in {
        formatConfigs = {
          vm = {config, ...}: shared // {};
          vm-bootloader = {config, ...}: shared // {};
        };
      }
    )
  ];
}
