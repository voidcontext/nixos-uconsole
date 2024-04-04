{nixpkgs, ...}: {pkgs, ...}: {
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot.kernelParams = ["console=serial0,115200" "console=tty1"];

  sdImage.compressImage = false;

  # TODO make this configurable
  users.mutableUsers = false;
  users.users.nixos = {
    password = "nixos";
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video"];
    shell = pkgs.bashInteractive;
  };

  networking.networkmanager.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";
  services.openssh.enable = true;
}
