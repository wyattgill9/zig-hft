with import <nixpkgs> {};

mkShell {
  buildInputs = [
    zig
    git
  ];

  shellHook = ''
    echo "Monorepo dev shell!"
  '';
}

