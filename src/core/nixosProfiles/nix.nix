{
  inputs,
  cell,
}: {
  pkgs,
  lib,
  config,
  ...
}: {
  nix = {
    nixPath = [
      "nixpkgs=${pkgs.path}"
    ];
    settings = {
      sandbox = true;
      auto-optimise-store = true;
      allowed-users = ["@wheel"];
      trusted-users = ["@wheel"];
    };
    gc.automatic = true;
    optimise.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes
      min-free = 5368709120
      fallback = true
    '';
  };
}
