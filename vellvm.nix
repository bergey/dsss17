{ stdenv, fetchgit, coq, paco, ocamlPackages, which, unzip
, tools ? stdenv.cc
}:

stdenv.mkDerivation {
  name = "vellvm-dsss-${coq.coq-version}-20170710";
  src = fetchgit {
    url = "https://github.com/vellvm/vellvm.git";
    rev = "5e0f2c979e080513ba829878b7ff38d403809c73";
    sha256 = "07miyimbin31m890i063f8lwln42blljfxkgkim8ms9cm6glyfd3";
  };

  buildInputs = [ coq.ocaml coq.camlp5 which unzip ocamlPackages.ocamlbuild ]
    ++ (with ocamlPackages; [ findlib menhir ]);
  propagatedBuildInputs = [ coq ];

  enableParallelBuilding = true;

  configurePhase = ''
    (cd lib; unzip ${paco.src})
  '';

  buildPhase = ''
    (cd lib/paco/src; make)
    (cd src; make)
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp src/vellvm $out/bin/vellvm
  '';

  meta = with stdenv.lib; {
    homepage = https://www.cis.upenn.edu/~stevez/vellvm/;
    license = licenses.gpl3;
    maintainers = [ maintainers.jwiegley ];
    platforms = coq.meta.platforms;
  };

}
