{
  description = "Sinh-x-ip_updater";

  inputs = {
    # NixPkgs (nixos-unstable)
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    # nixvim nix configuration
    nixvim = {
      url = "github:nix-community/nixvim";
      # url = "git+file:///Users/khaneliman/Documents/github/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";

    # Snowfall Lib
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Snowfall Flake
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      inherit (inputs) snowfall-lib;

      lib = snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          meta = {
            name = "sinh-x-ip_updater";
            title = "Sinh-x-ip_updater";
          };

          namespace = "sinh-x";
        };
      };
    in
    lib.mkFlake {
      alias = {
        packages = {
          default = "sinh-x-ip_updater";
        };
      };

      outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; };
    };
}
