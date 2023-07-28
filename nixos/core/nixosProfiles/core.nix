{
  inputs,
  cell,
}: targetName: {
  lib,
  config,
  ...
}: {
  console = {
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = map (l: "${l}/UTF-8") [
      "C.UTF-8"
      "en_US.UTF-8"
      "de_DE.UTF-8"
    ];
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  users.defaultUserShell = config.bee.pkgs.zsh;

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  documentation = {
    man.enable = true;
    doc.enable = false;
  };

  system.stateVersion = lib.mkDefault "23.05";
}
