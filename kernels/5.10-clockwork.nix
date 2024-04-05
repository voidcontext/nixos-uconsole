{
  nixpkgs,
  lib,
  cross,
}: let
  inherit (lib) callPackagesCrossAarch64;
  kernelPackagesCfg = {
    linuxPackagesFor,
    linux_rpi4,
    fetchFromGitHub,
    lib,
  }: let
    modDirVersion = "5.10.y";
    rev = "3a33f11c48572b9dd0fecac164b3990fc9234da8";
  in
    linuxPackagesFor (linux_rpi4.override {
      argsOverride = {
        version = "${modDirVersion}-${rev}";
        inherit modDirVersion;

        src = fetchFromGitHub {
          owner = "raspberrypi";
          repo = "linux";
          inherit rev;
          hash = "sha256-k+F64+WOFk78qHKrpcSTUZp+U0KLuWjvNIo0JiyLipQ=";
        };
      };
    });
in
  {
    pkgs,
    lib,
    ...
  }: {
    # Force cross compilation of the kernel, this way the kernel can be built on a stronger x86_64 machine
    # While the rest of the aarch64 build can use the binary cache
    # TODO: make cross-compilation configurable
    boot.kernelPackages =
      if cross
      then callPackagesCrossAarch64 kernelPackagesCfg {}
      else pkgs.callPackages kernelPackagesCfg {};

    boot.kernelPatches = [
      {
        name = "clockwork-uconsole";
        patch = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/clockworkpi/uConsole/b6920b37a0ea0319e8c16f7e96b552d32ff40ce8/Code/patch/cm4/20230630/0001-patch-cm4.patch";
          hash = "sha256-S34HCwIVYvn6R78qLWtH/XsTL5YFK99twoJMSnqk9Wc=";
        };
      }
    ];
  }
