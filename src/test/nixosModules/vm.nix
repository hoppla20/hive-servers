{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) types;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;

  cfg = config.hoppla.test;
in {
  imports = [inputs.nixos-generators.nixosModules.all-formats];

  options.hoppla.test.vm = {
    enable = helpers.mkEnableOption cfg.enable;

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
    forwardPorts = l.mkOption {
      type = types.listOf types.attrs;
      default = [];
    };
  };

  config = l.mkMerge [
    (
      let
        shared = {
          virtualisation = {
            inherit (cfg.vm) cores diskSize useEFIBoot resolution forwardPorts;
            memorySize = cfg.vm.memory;
            graphics = !cfg.vm.headless;
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
