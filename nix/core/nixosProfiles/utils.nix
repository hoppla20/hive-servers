{
  inputs,
  cell,
  config,
  options,
}: {
  environment.systemPackages = builtins.attrValues {
    inherit
      (inputs.nixpkgs)
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
