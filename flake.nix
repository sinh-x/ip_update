{
  description = "A Rust application";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rust = (import (pkgs.fetchFromGitHub {
          owner = "oxalica";
          repo = "rust-overlay";
          rev = "f5354a3a2a5d2b7a0a0b2d5b8b1aecfdc1fc0b77";
          sha256 = "sha256:0jmmwx2n1szpadj9b8f1w1q2b7pg7n3b2h2b9k5j9s9m7h7r9kjv";
        }) {
          inherit pkgs;
        }).rust-bin.stable.latest;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [ rust ];
          LD_LIBRARY_PATH = lib.makeLibraryPath [
            pkgs.openssl
          ];
      }
    );
}
