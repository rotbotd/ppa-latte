{
  description = "Explicit Latte terms for Principles of Program Analysis";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/7d1a7c21a4c00ea653fc7ed5c083d261340f185f";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      fstar = pkgs.fstar.overrideAttrs (old: {
        version = "2026.08.02";
        FSTAR_VERSION = "2026.08.02";
        FSTAR_COMMIT = "7bbcb5fa68a6581d7c379e39af0a38316de1e41f";
        FSTAR_COMMITDATE = "2026-08-02";
        src = pkgs.fetchgit {
          url = "https://github.com/FStarLang/FStar.git";
          rev = "7bbcb5fa68a6581d7c379e39af0a38316de1e41f";
          fetchSubmodules = true;
          hash = "sha256-KRfT2HS7ZsaLzcRjPQWqtBUW8hmrHCBpvfM+HYBxg6s=";
        };
        propagatedBuildInputs = old.propagatedBuildInputs ++ [
          pkgs.ocaml-ng.ocamlPackages_5_4.ctypes
          pkgs.ocaml-ng.ocamlPackages_5_4."ctypes-foreign"
          pkgs.ocaml-ng.ocamlPackages_5_4.fileutils
          pkgs.ocaml-ng.ocamlPackages_5_4.fix
          pkgs.ocaml-ng.ocamlPackages_5_4.uucp
          pkgs.ocaml-ng.ocamlPackages_5_4.visitors
          pkgs.ocaml-ng.ocamlPackages_5_4.wasm
        ];
        nativeBuildInputs = old.nativeBuildInputs ++ [
          pkgs.ocaml-ng.ocamlPackages_5_4.ocamlbuild
        ];
      });
    in {
      packages.${system}.default = pkgs.runCommand "ppa-latte-source" { } ''
        cp -r ${self} "$out"
      '';

      checks.${system}.policy = pkgs.runCommand "ppa-latte-policy" {
        nativeBuildInputs = [ pkgs.bash fstar pkgs.gnugrep ];
      } ''
        cp -r ${self} source
        chmod -R u+w source
        cd source
        bash scripts/check-policy
        fstar.exe --include generated/Chapter01 \
          generated/Chapter01/ReachingDefinitions.fst
        touch "$out"
      '';

      devShells.${system}.default = pkgs.mkShell {
        packages = [ fstar pkgs.nodejs_22 pkgs.shellcheck ];
        PPA_FSTAR_BIN = "${fstar}/bin/fstar.exe";
      };
    };
}
