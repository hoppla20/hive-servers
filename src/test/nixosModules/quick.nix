{ inputs
, cell
,
}: moduleName: { lib
               , config
               , options
               , ...
               }:
let
  l = lib // builtins;
  localLib = inputs.localLib;

  cfg = config.bee.modules.${moduleName};
in
{
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
  ];

  options = {
    diskSize = l.mkOption {
      type = l.types.ints.unsign;
      default = 10240;
    };
    useEFIBoot = localLib.mkEnableOption true;
    headless = localLib.mkEnableOption false;
    resolution = l.mkOption {
      type = l.types.submodule {
        options = {
          x = l.mkOption { type = l.types.int.unsign; };
          y = l.mkOption { type = l.types.int.unsign; };
        };
        default = {
          x = 1280;
          y = 800;
        };
      };
    };
  };

  config = {
    formatConfigs.vm-bootloader = { config, ... }: {
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
