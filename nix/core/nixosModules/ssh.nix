{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;

  cfg = config.hoppla.core;
in {
  options.hoppla.core.ssh = {
    enable = helpers.mkEnableOption cfg.enable;
    ports = l.mkOption {
      type = l.types.listOf l.types.ints.unsigned;
      default = [22];
    };
  };

  config = l.mkIf cfg.ssh.enable {
    services.openssh = {
      enable = true;
      inherit (cfg.ssh) ports;
      openFirewall = true;
    };
  };
}
