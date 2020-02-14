{ mkDerivation, base, pure, stdenv }:
mkDerivation {
  pname = "pure-loader";
  version = "0.8.0.0";
  src = ./.;
  libraryHaskellDepends = [ base pure ];
  homepage = "github.com/grumply/pure-loader";
  license = stdenv.lib.licenses.bsd3;
}
