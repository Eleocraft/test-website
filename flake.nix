{
  description = "Bun2nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bun2nix.url = "github:nix-community/bun2nix";
  };

  outputs = { self, nixpkgs, flake-utils, bun2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        lib = pkgs.lib;

        package = pkgs.callPackage ./default.nix {
          bun2nix = bun2nix.packages.${system}.default;
        };
      in
      {
        devShells.default =
        pkgs.mkShell {
          buildInputs = with pkgs; [
            bun
            svelte-check
            typescript-language-server
            svelte-language-server
          ];
        };

        packages.default = package;

        # OCI image serving the site
        packages.container = pkgs.callPackage ./container.nix {
          site = package;
        };
      }
    );
}
