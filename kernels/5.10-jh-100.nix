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
    modDirVersion = "5.10.110";
    rev = "8e1110a580887f4b82303b9354c25d7e2ff5860e";
  in
    linuxPackagesFor (linux_rpi4.override {
      argsOverride = {
        version = "${modDirVersion}-${rev}";
        inherit modDirVersion;

        src = fetchFromGitHub {
          owner = "raspberrypi";
          repo = "linux";
          inherit rev;
          hash = "sha256-G0XLIpiuszbHKetBQPSBxnyPggFDxUJ4B8F5poS9Tfg=";
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
        name = "jh-110-uconsole";
        patch = pkgs.fetchurl {
          # url = "https://gist.githubusercontent.com/JosephHewitt/69d6e2cbbdd23d7eb909374625daef94/raw/899d4067cc0d847e90bfbc7bac69cd7a6d3a7d2c/jh-uconsole-110.patch";
          url = "https://gist.githubusercontent.com/voidcontext/1017cad41b6a8a1ae781eca81c6e140a/raw/2887be532a8dafe604212e05cfc156fb6dc06fc9/jh-uconsole-110.patch";
          hash = "sha256-YcGuo2raC6AHOv1LE2/hKVrAvjq5ulyJygKA1j9H/wU=";
        };
        extraStructuredConfig = {
          DRM_PANEL_CWU50 = pkgs.lib.kernel.module;
          BACKLIGHT_OCP8178 = pkgs.lib.kernel.module;

          # Port over some configs from the official image
          # Source: https://jhewitt.net/uconsole
          REGMAP_I2C = pkgs.lib.kernel.yes;
          INPUT_AXP20X_PEK = pkgs.lib.kernel.yes;
          CHARGER_AXP20X = pkgs.lib.kernel.module;
          BATTERY_AXP20X = pkgs.lib.kernel.module;
          AXP20X_POWER = pkgs.lib.kernel.module;
          MFD_AXP20X = pkgs.lib.kernel.yes;
          MFD_AXP20X_I2C = pkgs.lib.kernel.yes;
          REGULATOR_AXP20X = pkgs.lib.kernel.yes;
          AXP20X_ADC = pkgs.lib.kernel.module;
          TI_ADC081C = pkgs.lib.kernel.module;
          CRYPTO_LIB_ARC4 = pkgs.lib.kernel.yes;
          CRC_CCITT = pkgs.lib.kernel.yes;
        };
      }
    ];
  }
