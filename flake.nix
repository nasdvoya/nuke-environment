{
  description = "CICD environment for dotnet and CI/CD.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

    in {
      devShells = forEachSupportedSystem ( { pkgs }: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Dotnet development
            (with dotnetCorePackages; combinePackages[ sdk_6_0 sdk_7_0 sdk_8_0 ])
            zlib zlib.dev
            openssl omnisharp-roslyn
            netcoredbg msbuild icu
            # Additional development tools
            # Add from: https://search.nixos.org/packages
            git-cliff
            just
          ];
          # Set up the environment variables
          shellHook = ''
            export NIX_LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc pkgs.openssl pkgs.zlib pkgs.icu ]}
            export NIX_LD=$(cat "${pkgs.stdenv.cc}/nix-support/dynamic-linker")
            '';
        };
      });
    };
}
