{
  inputs,
  super,
}: let
  inherit (inputs.nixpkgs) lib;
  l = lib // builtins;
in
  {
    inputs,
    cell,
    cellName,
    targetName,
    profiles ? false,
  }: loadInputs: path:
  # all files are modules
  {
    config,
    options,
    ...
  }: let
    flakePath = inputs.self.outPath;
    removeFileSuffix = l.removeSuffix ".nix";
    removeDefault = l.removeSuffix "/default";

    f = l.toFunction (import path);
    relModulePath = l.drop 6 (l.splitString "/" (toString path));
    relModulePathWithoutDefault = l.drop 7 (l.splitString "/" (removeDefault (removeFileSuffix (toString path))));

    cellPath = ["hoppla" cellName];

    targetPath = ["hoppla"] ++ l.optional profiles "profiles" ++ [cellName targetName];
    subModulePath = targetPath ++ relModulePathWithoutDefault;
    subModuleFilePath = cell.__cr ++ relModulePath;

    subModuleIdentifier =
      l.concatStringsSep "/"
      ([cellName targetName] ++ relModulePathWithoutDefault);

    cellCfg = l.getAttrFromPath cellPath config;
    targetCfg = l.getAttrFromPath targetPath config;
    submoduleCfg = l.getAttrFromPath subModulePath config;
  in
    l.pipe f [
      l.functionArgs
      (l.mapAttrs (name: _:
        l.getAttr name (loadInputs
          // {
            inherit
              config
              options
              cellPath
              targetPath
              cellCfg
              targetCfg
              ;

            selfPath = subModulePath;
            selfCfg = submoduleCfg;
          })))
      f
      (submodule: let
        file = "${flakePath}/nix/${l.concatStringsSep "/" subModuleFilePath}";
      in
        {
          _file = file;
          imports = l.attrByPath ["imports"] [] submodule;
          config =
            l.mkIf targetCfg.enable
            (
              if l.hasAttr "config" submodule
              then submodule.config
              else l.removeAttrs submodule ["imports" "options"]
            );
        }
        // l.optionalAttrs (! profiles) {
          options = l.setAttrByPath subModulePath (l.attrByPath ["options"] {} submodule);
        })
    ]
