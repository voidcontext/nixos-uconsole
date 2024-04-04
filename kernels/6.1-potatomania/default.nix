{
  nixpkgs,
  nixos-hardware,
  lib,
  cross,
}: let
  inherit (lib) callPackagesCrossAarch64;
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
in
  {
    pkgs,
    config,
    ...
  }: let
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
    imports = [
      nixos-hardware.nixosModules.raspberry-pi-4
    ];

    # boot.initrd.availableKernelModules = [
    #   "usbhid"
    #   "usb_storage"
    #   "vc4"
    #   # "pcie_brcmstb" # required for the pcie bus to work
    #   # "reset-raspberrypi" # required for vl805 firmware to load
    # ];
    # Force cross compilation of the kernel, this way the kernel can be built on a stronger x86_64 machine
    # While the rest of the aarch64 build can use the binary cache
    # TODO: make this configurable
    boot.kernelPackages =
      if cross
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

    boot.loader.raspberryPi.firmwareConfig = ''
      [cm4]
      arm_boost=1
      max_framebuffers=2
      [all]
      ignore_lcd=1
      disable_fw_kms_setup=1
      disable_audio_dither
      pwm_sample_bits=20

      # setup headphone detect pin
      gpio=10=ip,np

      dtparam=audio=on
      dtparam=spi=on
    '';

    hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    hardware.raspberry-pi."4".dwc2.enable = true;
    hardware.raspberry-pi."4".dwc2.dr_mode = "host";
    hardware.deviceTree.enable = true;
    hardware.deviceTree.overlays = [
      {
        name = "uconsole,cm4";
        dtsFile = ./uconsole-overlay.dts;
        filter = "bcm2711-rpi-cm4.dtb";
      }
      {
        name = "vc4-kms-v3d-pi4,cma-384";
        dtboFile = "${config.boot.kernelPackages.kernel}/dtbs/overlays/vc4-kms-v3d-pi4.dtbo";
        filter = "bcm2711-rpi-cm4.dtb";
      }
      {
        name = "audremap,pins_12_13";
        dtboFile = "${config.boot.kernelPackages.kernel}/dtbs/overlays/audremap.dtbo";
        filter = "bcm2711-rpi-cm4.dtb";
      }
    ];
  }
