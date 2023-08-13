{
  inputs,
  cell,
  config,
  options,
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

  users.defaultUserShell = inputs.nixpkgs.zsh;

  environment.pathsToLink = ["/share/zsh"];
}
