{
  description = "Command line tool to update public IP address to Wasabi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "sinh-x-ip_updater";
          version = "0.2.0";
          src = ./.;
          cargoSha256 = "sha256-nfkVUSHjCnfYqrxed2C+KlqhBjQ2mL3v8K5P6OkRzFI";
          buildInputs = [pkgs.openssl];
          nativeBuildInputs = [pkgs.cargo pkgs.rustc pkgs.pkg-config pkgs.openssl];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
          ];
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.cargo
            pkgs.rustc
            pkgs.pkg-config
            pkgs.openssl
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.openssl
          ];
        };
      }
    );
}
