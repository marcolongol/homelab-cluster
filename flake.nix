{
  description = "Homelab cluster dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Python build dependencies
          gcc
          gnumake
          pkg-config
          zlib
          openssl
          readline
          bzip2
          libffi
          ncurses
          xz
          sqlite
          pipx
        ];
      };
    };
}
