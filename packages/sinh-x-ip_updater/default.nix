{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  # You also have access to your flake's inputs.

  # The namespace used for your flake, defaulting to "internal" if not set.

  # All other arguments come from NixPkgs. You can use `pkgs` to pull packages or helpers
  # programmatically or you may add the named attributes as arguments here.
  pkgs,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  pname = "sinh-x-ip_updater";
  version = "0.2.0";
  src = ../..;
  cargoSha256 = "sha256-nfkVUSHjCnfYqrxed2C+KlqhBjQ2mL3v8K5P6OkRzFI";
  buildInputs = [ pkgs.openssl ];
  nativeBuildInputs = [
    pkgs.cargo
    pkgs.rustc
    pkgs.pkg-config
    pkgs.openssl
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl ];
}
