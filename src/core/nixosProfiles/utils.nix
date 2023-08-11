{
  inputs,
  cell,
}: {
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      coreutils
      dnsutils
      iputils
      pciutils
      # monitoring
      
      bottom
      # partitioning
      
      parted
      gptfdisk
      # useful tools
      
      curl
      wget
      git
      neovim
      pv
      ripgrep
      gawk
      gnused
      killall
      rename
      tldr
      # parsers
      
      jq
      yq
      ;
  };
}
