{
  description = "A Rust application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        defaultPackage = pkgs.rustPlatform.buildRustPackage rec {
          pname = "ip_updater";
          version = "0.1.0";
          src = ./.;
          cargoSha256 = "sha256:188516aj66zbjjgnsnhc6fnqa216q6dfddv4vblg8xyq5rd8b09p";
          buildInputs = [ pkgs.openssl ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
          ];
        };

        devShell = pkgs.mkShell {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
          ];
        };
      }
    );
}
