/*
Inputs:
flakeRoot = {
  system1 = {
    cell1 = {
      block1 = {
        target1 = "cell1-block1-target1";
      };
    };
    cell2 = {
      block1 = {
        target1 = "cell2-block1-target1";
      };
      block2 = {
        target1 = "cell2-block2-target1";
        target2 = "cell2-block2-target2";
      };
    };
  };
}
blockName = "block1"

Outputs:
{
  system1 = {
    cell1 = {
      target1 = "cell1-block1-target1";
    };
    cell2 = {
      target1 = "cell2-block1-target1";
      target2 = "cell2-block1-target2";
    };
  };
}
*/
{inputs}: {
  harvest = flakeRoot: blockName: let
    inherit (inputs.nixpkgs) lib;

    l = lib // builtins;
  in
    l.mapAttrs (_: cells: l.filterAttrs (_: v: v != {}) (l.mapAttrs (cell: l.attrByPath [blockName] {}) cells)) (l.filterAttrs (k: v: l.elem k l.systems.doubles.all) flakeRoot);
}
