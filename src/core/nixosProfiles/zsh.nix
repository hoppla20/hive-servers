{
  inputs,
  cell,
}: {
  pkgs,
  lib,
  config,
  ...
}: {
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    starship.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  environment.pathsToLink = ["/share/zsh"];
}
