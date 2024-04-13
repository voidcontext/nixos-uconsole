{nixpkgs, ...}: {
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  options = {
    uconsole.boot.configTxt = with lib;
      mkOption {
        type = types.string;
      };
    uconsole.boot.kernel.crossBuild = with lib;
      mkOption {
        type = types.bool;
      };
  };

  config = {
    boot.kernelParams = ["console=serial0,115200" "console=tty1"];

    system.stateVersion = "23.11";

    sdImage.compressImage = false;
    sdImage.populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" config.uconsole.boot.configTxt;
    in ''
      # Add the config
      rm -f firmware/config.txt
      cp ${configTxt} firmware/config.txt
    '';

    networking.networkmanager.enable = true;
    powerManagement.cpuFreqGovernor = "ondemand";
    services.openssh.enable = true;

    # ---- Some extra stuff, this should be removed or make it configurable
    # TODO make this configurable
    users.mutableUsers = false;
    users.users.nixos = {
      password = "nixos";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];
      shell = pkgs.bashInteractive;
    };

    programs.git.enable = true;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
