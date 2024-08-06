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
        pkgs = nixpkgs.legacypackages.${system};
      in {
        defaultpackage = pkgs.rustplatform.buildrustpackage {
          pname = "ip_update";
          version = "0.1.0";
          src = ./.;
          cargosha256 = "sha256-qd3lgdxnaxr4vunxwchw80vffeap1jylgq5bkdccdge=";
          buildinputs = [pkgs.openssl];
          nativebuildinputs = [pkgs.cargo pkgs.rustc pkgs.pkg-config pkgs.openssl];
          ld_library_path = pkgs.lib.makelibrarypath [
            pkgs.openssl
          ];
        };

        devshell = pkgs.mkshell {
          buildinputs = [pkgs.openssl];
          ld_library_path = pkgs.lib.makelibrarypath [
            pkgs.openssl
          ];
        };
      }
    );
}
