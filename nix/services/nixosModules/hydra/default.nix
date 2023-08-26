{
  inputs,
  cell,
  config,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  inherit (lib) types;
  l = lib // builtins;

  mkStr = l.mkOption {type = types.str;};

  createUserCommands = {
    name,
    passwordFile,
    roles,
  }: ''
    # create user ${name}

    hydra-create-user "${name}" \
      --wipe-roles \
      ${l.concatStringsSep " " (l.map (role: "--role \"${role}\"") roles)} \
      --password-hash "$(cat "${passwordFile}" | argon2 "$(LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c16)" -id -k 262144 -l 16 -e)"
  '';
in {
  options = {
    ensureUsers = l.mkOption {
      type = types.listOf (types.submodule (_: {
        options = {
          name = mkStr;
          passwordFile = mkStr;
          roles = l.mkOption {
            type = types.listOf types.str;
            default = [];
          };
        };
      }));
      default = [];
    };
    localMaxJobs = l.mkOption {
      type = types.int;
      default = 1;
    };

    config = l.mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = {
    services.hydra =
      selfCfg.config
      // {
        extraConfig = ''
          <dynamicruncommand>
            enable = 1
          </dynamicruncommand>
        '';
      };

    systemd.services.hydra-ensure-users = {
      description = "Ensure that Hydra users are present";

      wantedBy = ["multi-user.target"];
      after = ["hydra-init.service"];

      path = [config.services.hydra.package inputs.nixpkgs.libargon2];
      script = ''
        ${l.concatStringsSep "\n\n" (l.map createUserCommands selfCfg.ensureUsers)}
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "hydra";
        Group = "hydra";
      };
    };

    networking.firewall.allowedTCPPorts = [config.services.hydra.port];

    nix = {
      settings.allowed-users = ["hydra"];
      buildMachines = [
        {
          hostName = "localhost";
          system = "x86_64-linux";
          supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
          maxJobs = selfCfg.localMaxJobs;
        }
      ];
    };
  };
}
