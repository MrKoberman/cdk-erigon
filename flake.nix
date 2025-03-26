{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    systems.url = "github:nix-systems/default";
    foundry.url = "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases
  };

  outputs = { self, nixpkgs, systems, foundry, ... }@inputs:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs (import systems) (system:
          f (import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
            overlays = [
              foundry.overlay
            ];
          }));
    in {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          hardeningDisable = [ "all" ];
          buildInputs = [ ];

          packages = [
            # Golang Toolchain
            pkgs.delve
            pkgs.go_1_22
            pkgs.gotools
            pkgs.gopls
            pkgs.go-outline
            pkgs.gopkgs
            pkgs.godef
            pkgs.golangci-lint
            pkgs.go-tools

            # C/C++ Toolchain
            pkgs.gcc
            pkgs.cmake

            # Libraries: Google Test, OpenMP, GMP
            pkgs.gtest.dev          # Precompiled static libs + headers
            pkgs.llvmPackages.openmp
            pkgs.gmp

            # Foundry
            pkgs.foundry

            pkgs.trivy
          ];
        };
      });
    };
}