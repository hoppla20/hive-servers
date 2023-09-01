{
  inputs,
  cell,
  config,
}: let
  inherit (inputs.nixpkgs) lib;
  l = lib // builtins;
in {
  services.nginx = {
    statusPage = lib.mkDefault true;

    recommendedBrotliSettings = lib.mkDefault true;
    recommendedGzipSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedZstdSettings = lib.mkDefault true;

    # Nginx sends all the access logs to /var/log/nginx/access.log by default.
    # instead of going to the journal!
    commonHttpConfig = "access_log syslog:server=unix:/dev/log;";

    sslDhparam = config.security.dhparams.params.nginx.path;
  };

  security.dhparams = {
    enable = true;
    params.nginx = {};
  };
}
