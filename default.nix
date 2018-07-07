{ mkDerivation, base, pure, pure-visibility, stdenv }:
mkDerivation {
  pname = "pure-loader";
  version = "0.7.0.0";
  src = ./.;
  libraryHaskellDepends = [ base pure pure-visibility ];
  homepage = "github.com/grumply/pure-loader";
  license = stdenv.lib.licenses.bsd3;
}