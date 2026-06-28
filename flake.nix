{
  description = "xmonad config editing environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    hpkgs = pkgs.haskellPackages;
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        (hpkgs.ghcWithPackages (p: [
          p.hoogle
          p.xmonad
          p.xmonad-contrib
        ]))

        hpkgs.haskell-language-server
        hpkgs.fourmolu
      ];
    };
  };
}
