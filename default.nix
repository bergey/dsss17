let
  fetchNixpkgs = import ./fetchNixpkgs.nix;

  nixpkgs = fetchNixpkgs (builtins.fromJSON (builtins.readFile ./nixpkgs-snapshot.json));
        
  pkgs = import nixpkgs { config = {
    allowUnfree = true;         # because we haven't set license params
    allowBroken = true;
  };};

  haskellPkgs = pkgs.haskell.packages.ghc802;

  inherit (pkgs) stdenv;
  inherit (pkgs.haskell.lib) dontCheck dontHaddock;

  callPackage = stdenv.lib.callPackageWith (pkgs // haskellPkgs // haskellDeps);

  withSrc = path: deriv: pkgs.stdenv.lib.overrideDerivation deriv (attrs: {
    src = path;
  });

  withPatches = patches: deriv: pkgs.stdenv.lib.overrideDerivation deriv (attrs: {
    patches = patches;
  });

  haskellDeps = pkgs.recurseIntoAttrs rec {
    lngen = withSrc ./lngen (callPackage ./lngen.nix {});
  };

  dependencies = rec {
    coqrel = callPackage ./coqrel.nix {};

    compcert = callPackage ./compcert.nix {};

    QuickChick = withPatches [./QuickChick.patch]
      (withSrc ./QuickChick (callPackage ./QuickChick.nix {}));

    paco = callPackage ./paco.nix {};
    vellvm = withSrc ./vellvm (callPackage ./vellvm.nix {
      paco = callPackage ./paco.nix {};
    });

    metalib = callPackage ./metalib.nix {
      haskellPackages = haskellPkgs // haskellDeps;
    };

    vst = callPackage ./vst.nix {};
  };

  software = with pkgs; [
    # Coq
    ocaml
    ocamlPackages.camlp5_transitional
    coq_8_6
    coqPackages_8_6.dpdgraph
    coqPackages_8_6.coq-ext-lib

    # ssreflect
    # coqPackages_8_6.mathcomp
    coqPackages_8_6.ssreflect

    # QuickChick
    dependencies.QuickChick

    # Vellvm
    dependencies.paco
    dependencies.vellvm

    # Ott
    ott

    # Compcert
    dependencies.compcert
    ocamlPackages.menhir
    ocamlPackages.findlib

    # lngen
    haskellDeps.lngen

    # Metalib
    dependencies.metalib

    # VST
    dependencies.vst

    # GHC
    haskellPkgs.ghc
    haskellPkgs.alex
    haskellPkgs.happy
    haskellPkgs.cabal-install
    haskellPkgs.hlint

    # Editors
    vim
    emacs
      emacsPackages.proofgeneral_HEAD
      emacsPackagesNg.use-package
      emacsPackagesNg.company-coq
      emacsPackagesNg.tuareg
      emacsPackagesNg.dash
  ];

  build = with pkgs; pkgs.buildEnv {
    name = "dsss17";
    paths = software;
  };

in rec {
  env = with pkgs; pkgs.myEnvFun {
    name = "dsss17";
    buildInputs = software;
  };

  options = {
    dependencies = dependencies;
    build = build;
  };
}
