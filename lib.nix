{nixpkgs}: {
  callPackagesCrossAarch64 = fn: let
    p = import nixpkgs {localSystem = "x86_64-linux";};
    cross = p.pkgsCross.aarch64-multiplatform;
    callPackage = cross.lib.callPackageWith (cross // {inherit callPackage;});
  in
    callPackage fn;
}
