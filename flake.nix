{
  description = "Zig development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig
            zls
            gdb
            scc
            hyperfine
          ];

          shellHook = ''
            echo "Zig development environment"
            echo "Zig version: $(zig version)"
            echo "ZLS available for LSP support"
            
            # export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-cache"
          '';
        };

      });
}
