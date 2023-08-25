{
  inputs,
  options,
  targetCfg,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) types;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;
in {
  options = {
    enable = helpers.mkEnableOption targetCfg.enable;
    timeServers =
      options.networking.timeServers
      // {
        default = [
          "0.de.pool.ntp.org"
          "1.de.pool.ntp.org"
          "2.de.pool.ntp.org"
          "3.de.pool.ntp.org"
        ];
      };

    hostId = lib.mkOption {
      type = types.str;
      default = builtins.substring 0 8 (builtins.hashString "md5" targetCfg.hostName);
    };
  };

  config = l.mkIf selfCfg.enable {
    networking = {
      inherit (selfCfg) hostId timeServers;
      firewall.enable = true;
    };

    # TODO remove later
    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
