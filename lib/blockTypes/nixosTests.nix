{
  inputs,
  root,
}: let
  inherit (root.helpers) mkCommand;
in {
  name = "nixosTests";
  type = "nixosTests";
  actions = {
    inputs,
    currentSystem,
    fragment,
    fragmentRelPath,
    target,
  }: [
    (mkCommand
      currentSystem
      "run"
      "build and run the test in interactive mode"
      [inputs.nixpkgs.nix-output-monitor]
      ''
        RESULT=$(nom build --no-link --print-out-paths "$PRJ_ROOT#"'${fragment}'".driver")
        exec "$RESULT/bin/nixos-test-driver"
      ''
      {})
    (mkCommand
      currentSystem
      "runInteractive"
      "build and run the test in interactive mode"
      [inputs.nixpkgs.nix-output-monitor]
      ''
        RESULT=$(nom build --no-link --print-out-paths "$PRJ_ROOT#"'${fragment}'".driverInteractive")
        exec "$RESULT/bin/nixos-test-driver"
      ''
      {})
  ];
}
