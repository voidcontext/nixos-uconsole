{
  description = "NixOS support for clockworkPi uConsole";

  inputs.nixpkgs.url = "nixpkgs/release-23.11";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
  }: let
    system = "aarch64-linux";

    overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // {allowMissing = true;});
      })
      # (final: super: {zfs = super.zfs.overrideAttrs (_: {meta.platforms = [];});}) # disable zfs
    ];

    pkgs = import nixpkgs {inherit system overlays;};

    base-module = import ./module.nix {inherit nixpkgs nixos-hardware;};

    base-system-cm4 = nixpkgs.lib.nixosSystem {
      inherit system pkgs;

      modules = [base-module];
    };
  in {
    images.sd-image-cm4 = base-system-cm4.config.system.build.sdImage;
  };
}
