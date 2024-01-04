{ lib, stdenv, installShellFiles, sources }:
stdenv.mkDerivation rec {
  inherit (sources.okteto-bin) src version;
  name = lib.removeSuffix "-bin" sources.okteto-bin.pname;
  phases = [ "installPhase" "postInstall" ];

  nativeBuildInputs = [ installShellFiles ];

  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r $src $out/bin/${name}
    chmod +x $out/bin/${name}
  '';

  # NOTE: https://github.com/NixOS/nixpkgs/issues/16144#issuecomment-225422439
  postInstall = ''
    export HOME=$TMP
    installShellCompletion --cmd ${name} \
      --bash <($out/bin/${name} completion bash) \
      --fish <($out/bin/${name} completion fish) \
      --zsh <($out/bin/${name} completion zsh)
  '';
}
