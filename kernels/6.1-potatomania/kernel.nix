{
  nixpkgs,
  pkgs,
  config,
  ...
}: let
  cfg = config.uconsole.boot.kernel;

  localLib = import ../../lib.nix {inherit nixpkgs;};
  inherit (localLib) callPackagesCrossAarch64;

  kernelPackagesCfg = {
    linuxPackagesFor,
    linux_rpi4,
    fetchFromGitHub,
  }: let
    # Version picked from the current (as of 3rd Apr 2024) nixpkgs-unstable branch
    modDirVersion = "6.1.63";
    tag = "stable_20231123";
  in
    linuxPackagesFor (linux_rpi4.override {
      argsOverride = {
        version = "${modDirVersion}-${tag}";
        inherit modDirVersion;

        src = fetchFromGitHub {
          owner = "raspberrypi";
          repo = "linux";
          rev = tag;
          hash = "sha256-4Rc57y70LmRFwDnOD4rHoHGmfxD9zYEAwYm9Wvyb3no=";
        };
      };
    });
  # These patches are copied over from:
  # https://github.com/PotatoMania/uconsole-cm3/tree/1bfce6701e6ac9f1c2fdfc75fcd4cbc184a13813/PKGBUILDs/linux-uconsole-cm3-rpi64
  #
  # TODO: find a better way of declare attribution
  patches = [
    ./patches/0001-video-backlight-Add-OCP8178-backlight-driver.patch
    ./patches/0002-drm-panel-add-clockwork-cwu50.patch
    ./patches/0003-driver-staging-add-uconsole-simple-amplifier-switch.patch
    # The device tree patch is not applied to the kernel at compile time (to avoid rebuild),
    # but merged later using NixOS' `hardware.deviceTree` confdig.
    # ./patches/0004-arm-dts-overlays-add-uconsole.patch
    ./patches/0005-drivers-power-axp20x-customize-PMU.patch
    ./patches/0006-power-axp20x_battery-implement-calibration.patch
    ./patches/0007-drm-panel-cwu50-expose-dsi-error-status-to-userspace.patch
  ];
in {
  boot.kernelPackages =
    if cfg.crossBuild
    then callPackagesCrossAarch64 kernelPackagesCfg {}
    else pkgs.callPackages kernelPackagesCfg {};

  boot.initrd.kernelModules = [
    "ocp8178-bl"
    "panel-clockwork-cwu50"
    "simple-amplifier-switch"
  ];

  boot.kernelPatches =
    (
      builtins.map (patch: {
        name = patch + "";
        patch = patch;
      })
      patches
    )
    ++ [
      {
        name = "uconsole-config";
        patch = null;
        extraStructuredConfig = {
          # Enable the newly patched modules
          DRM_PANEL_CLOCKWORK_CWU50 = pkgs.lib.kernel.module;
          SIMPLE_AMPLIFIER_SWITCH = pkgs.lib.kernel.module;
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
