{
  inputs,
  cell,
  config,
  options,
}: {
  imports =
    builtins.attrValues inputs.nixosProfiles.test
    ++ [cell.nixosModules.nextcloud];

  hoppla = {
    core.hostName = "nextcloud";
    services.nextcloud = {
      enable = true;
      hostName = "nextcloud";
      adminpassFile = "/run/secrets/services/nextcloud/adminpass";
      database = {
        type = "pgsql";
        name = "nextcloud";
        user = "nextcloud";
      };
    };
  };

  sops = {
    defaultSopsFile = ./__secrets/test/default.sops.yaml;
    secrets = let
      nextcloudSecret = {
        mode = "0400";
        owner = config.users.users.nextcloud.name;
        inherit (config.users.users.nextcloud) group;
        restartUnits = ["nextcloud-setup.service"];
      };
    in {
      "services/nextcloud/adminpass" = nextcloudSecret;
      "services/nextcloud/dbpass" = nextcloudSecret;
    };
  };
}
