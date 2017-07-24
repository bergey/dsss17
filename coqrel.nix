{ stdenv, fetchgit, coq, ocamlPackages, haskellPackages, which
}:

let targetPlatform = if stdenv.isDarwin then "x86_64-macosx" else "x86_64-linux";

in stdenv.mkDerivation {
  name = "coqrel-${coq.coq-version}-20170723";
  src = fetchgit {
    url = "https://github.com/CertiKOS/coqrel.git";
    rev = "c26a275bfa2c755fb2aba5637cd40c7474723d03";
    sha256 = "13ldpw99y9l1b8ajwm4rzsb2wysdsf3h1zmhaalh82gry1da1rzf";
  };

  buildInputs = [ coq.ocaml coq.camlp5 which coq ]
    ++ (with ocamlPackages; [ findlib ]);
  propagatedBuildInputs = [ coq ];

  enableParallelBuilding = true;

  configurePhase = ''
    ./configure
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    COQLIB=$out/lib/coq/${coq.coq-version}/
    mkdir -p $COQLIB/user-contrib/coqrel
    cp -pR *.vo $COQLIB/user-contrib/coqrel
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/CertiKOS/coqrel;
    license = licenses.mit;
    maintainers = [ maintainers.dredozubov ];
    platforms = coq.meta.platforms;
  };
}
