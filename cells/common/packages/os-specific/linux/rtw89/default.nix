{ lib, stdenv, sources, kernel ? nil, ... }:

let
  modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  inherit (sources.rtw89) pname src version;
  name = "rtw89-${kernel.version}-${version}";

  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernel.makeFlags ++ [ "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p ${modDestDir}
    find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
    find ${modDestDir} -name '*.ko' -exec xz -f {} \;

    runHook postInstall
  '';

  meta = with lib; {
    description = " Driver for Realtek 8852AE, 8852BE, and 8853CE, 802.11ax devices";
    homepage = "https://github.com/lwfinger/rtw89";
    license = with licenses; [ gpl2Only ];
    maintainers = with maintainers; [ tvorog ];
    platforms = platforms.linux;
    # broken = kernel.kernelOlder "5.7";
    # priority = -1;
  };
}
