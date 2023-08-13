{
  inputs,
  cell,
}: {pkgs, ...}: let
  servicesBase = {
    restart = "unless-stopped";
  };
in {
  project.name = "nextcloud";
  enableDefaultNetwork = true;
  docker-compose = {
    volumes = {
      db = {};
    };
  };
  services = {
    db.service =
      servicesBase
      // {
        image = "postgres:alpine";
        volumes = [
          "db:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_DB = "nextcloud";
          POSTGRES_USER = "nextcloud";
          POSTGRES_PASSWORD = "nextcloud";
        };
      };
  };
}
