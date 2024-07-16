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
          pname = "ip_update";
          version = "0.1.0";
          src = ./.;
          cargoSha256 = "sha256-QD3LgDxnAXR4VUnXwchW80vffeAp1JylGq5bKdCcdgE=";
          buildInputs = [ pkgs.openssl ];
          nativeBuildInputs = [ pkgs.cargo pkgs.rustc pkgs.pkg-config pkgs.openssl ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
          ];
        };

        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.openssl ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
          ];
        };
      }
    );
}
