{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;

  cfg = config.hoppla.users.vincentcui;
in {
  options.hoppla.users.vincentcui = {
    enable = helpers.mkEnableOption false;
  };

  config = l.mkIf cfg.enable (l.mkMerge [
    {
      users.users.vincentcui = {
        uid = 1000;
        description = "Vincent Cui";
        isNormalUser = true;
        hashedPassword = "$6$rounds=4096$BGIzgpigyvSnrnak$dOv/C2.bZjDqWYvPTic/rf6nIrvUDFmBuOmvQLzTNjSdm28xQBF7JSnIxlXTpdauAuPZQbSxRvJ18grEmg/Pd0";
        openssh.authorizedKeys.keyFiles = [./__ssh/yubikey.pub ./__ssh/nitrokey.pub];
        extraGroups = [
          "wheel"
          "networkmanager"
          # desktop
          "video"
          "audio"
          "lp" # printer
          # virtualisation
          "libvirtd"
          "docker"
          "podman"
          # hardware
          "nitrokey"
        ];
      };

      security.sudo.extraRules = [
        {
          users = ["vincentcui"];
          commands = [
            {
              command = "${inputs.nixpkgs.nixos-rebuild}/bin/nixos-rebuild";
              options = ["SETENV" "NOPASSWD"];
            }
            {
              command = "/nix/var/nix/profiles/system/specialisation/*/bin/switch-to-configuration";
              options = ["SETENV" "NOPASSWD"];
            }
          ];
        }
      ];
    }
  ]);
}
