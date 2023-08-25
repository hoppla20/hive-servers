{
  inputs,
  cell,
}:
#}: let
#  repoUrl = "registry.vincentcui.de:443/server/hive-servers";
#in
inputs.nixpkgs.lib.mapAttrs
(name: target: inputs.std.lib.ops.mkOCI ({inherit name;} // target))
{
  hello = {
    entrypoint = inputs.nixpkgs.hello;
    # perms = []; { path ? "", regex = "", mode = "" }
    # uid = 65534;
    # gid = 65534;
    # setup = [ list of pkgs.write... files, can be used by entrypoint for setup?
    #   passthru = {
    #     perms = [];
    #   };
    # ];
    # config = {}; additional config passed to n2c.buildImage
    # options = {}; additional options to n2c.buildImage
    # tag = ""; defaults to output hash
    # labels = {}; will be prefixed with 'org.opencontainers.image'
    # layers = []; see n2c.buildLayer
    # runtimeInputs = []; ?
    # meta = {}; n2c meta attribute
  };
}
