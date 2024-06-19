# This Nix flake is managed as a dream2nix project.
#
# - https://nix-community.github.io/dream2nix/
{
  description = "Faststream. A powerful and easy-to-use Python framework for building asynchronous services interacting with event streams";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
    iggy = {
      url = "github:rupurt/iggy?rev=e27b21ac24c3009b4abdb87090a3cf4d14e7410e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    dream2nix,
    nixpkgs,
    iggy,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (supportedSystem:
        f rec {
          system = supportedSystem;
          pkgs = import nixpkgs {
            system =
              if system == "aarch64-darwin"
              then "x86_64-darwin"
              else system;
            config.allowUnfree = true;
            overlays = [
              iggy.overlay
            ];
          };
        });
  in {
    packages = forEachSupportedSystem ({pkgs, ...}: {
      default = dream2nix.lib.evalModules {
        packageSets.nixpkgs = pkgs;
        modules = [
          ./default.nix
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
            paths.lockFile =
              if pkgs.stdenv.isDarwin
              then "lock.default.darwin.json"
              else "lock.default.linux.json";
            flags.extraRabbit = true;
            flags.extraKafka = true;
            flags.extraConfluent = true;
            flags.extraNats = true;
            flags.extraRedis = true;
            flags.extraOtel = true;
            flags.pipFlattenDependencies = true;
          }
        ];
      };
      dev = dream2nix.lib.evalModules {
        packageSets.nixpkgs = pkgs;
        modules = [
          ./default.nix
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
            paths.lockFile =
              if pkgs.stdenv.isDarwin
              then "lock.dev.darwin.json"
              else "lock.dev.linux.json";
            flags.extraDev = true;
            # flags.extraTesting = true;
            flags.pipFlattenDependencies = true;
          }
        ];
      };
    });

    # nix run
    apps = forEachSupportedSystem ({ pkgs, ... }: {
    });

    formatter = forEachSupportedSystem ({pkgs, ...}: pkgs.alejandra);

    devShells = forEachSupportedSystem ({
      system,
      pkgs,
      ...
    }: {
      default = pkgs.mkShell {
        inputsFrom = [
          self.packages.${system}.dev.devShell
        ];

        packages = with pkgs; [ ]
        ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
          iggy-pkgs.cli
        ];

        shellHook = ''
          export PATH=$(realpath .)/.dream2nix/python/bin:$PATH
          export PYTHONPATH=$(realpath .)/.dream2nix/python/site:$PYTHONPATH
        '';
      };
    });

    overlay = final: prev: {
      faststream = self.packages.${prev.system};
    };
  };
}
