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
}
