{nixpkgs, ...}: {pkgs, ...}: {
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot.kernelParams = ["console=serial0,115200" "console=tty1"];

  system.stateVersion = "23.11";

  sdImage.compressImage = false;

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
}
