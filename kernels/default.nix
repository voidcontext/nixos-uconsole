{
  nixpkgs,
  nixos-hardware,
  lib,
}: {
  "6.1-potatomania" = import ./6.1-potatomania {
    inherit nixpkgs lib nixos-hardware;
    cross = false;
  };
  "6.1-potatomania-cross-build" = import ./6.1-potatomania {
    inherit nixpkgs lib nixos-hardware;
    cross = true;
  };
  "5.10-clockwork" = import ./5.10-clockwork.nix {
    inherit nixpkgs lib;
    cross = false;
  };
  "5.10-clockwork-cross-build" = import ./5.10-clockwork.nix {
    inherit nixpkgs lib;
    cross = true;
  };
  "5.10-jh-110" = import ./5.10-jh-100.nix {
    inherit nixpkgs lib;
    cross = false;
  };
  "5.10-jh-110-cross-build" = import ./5.10-jh-100.nix {
    inherit nixpkgs lib;
    cross = true;
  };
}
