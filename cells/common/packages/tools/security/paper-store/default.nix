{ sources, stdenv }:
stdenv.mkDerivation rec {
  inherit (sources.paper-store) src pname version;
  installPhase = ''
    mkdir -p $out/bin
    install -m755 $src/paper_store_dense.sh $out/bin/paper_store_dense
    install -m755 $src/paper_store_sparse.sh $out/bin/paper_store_sparse
  '';
}
