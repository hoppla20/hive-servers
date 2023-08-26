{
  inputs,
  cell,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;
in {
  options = {
    enable = helpers.mkEnableOption false;
  };

  config = l.mkIf selfCfg.enable (l.mkMerge [
    {
      users.users."vincent.cui" = {
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
          users = ["vincent.cui"];
          commands = [
            {
              command = "ALL";
              options = ["SETENV" "NOPASSWD"];
            }
          ];
        }
      ];
    }
  ]);
}
