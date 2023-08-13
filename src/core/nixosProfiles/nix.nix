{
  inputs,
  cell,
  config,
  options,
}: {
  nix = {
    nixPath = [
      "nixpkgs=${inputs.nixpkgs.path}"
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
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
