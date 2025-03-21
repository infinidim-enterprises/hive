# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  lobe-chat = {
    pname = "lobe-chat";
    version = "1.71.3";
    src = dockerTools.pullImage {
      imageName = "lobehub/lobe-chat";
      imageDigest = "sha256:9b2108f9158226b47fdaefe9069873b7e2c8b4befddc6994d7030b7ccf9f08ea";
      sha256 = "sha256-ykU5I9kPUBAdCuB+46lH+LzYK40xa4DFCtBZ7oCKSRg=";
      finalImageTag = "latest";
    };
  };
  rock-pi-x-firmware = {
    pname = "rock-pi-x-firmware";
    version = "20200828-0711";
    src = fetchurl {
      url = "https://dl.radxa.com/rockpix/drivers/firmware/AP6255_BT_WIFI_Firmware.zip";
      sha256 = "sha256-G5Q0/N02G3eO/+S1ELhOcX4+znWJz67FXsiUTvmDYAM=";
    };
  };
  rtl88x2bu = {
    pname = "rtl88x2bu";
    version = "f0644acaa8b906a94a5176d7afc9efc988239fcb";
    src = fetchFromGitHub {
      owner = "RinCat";
      repo = "RTL88x2BU-Linux-Driver";
      rev = "f0644acaa8b906a94a5176d7afc9efc988239fcb";
      fetchSubmodules = false;
      sha256 = "sha256-TzZXBOEAl1ndEUhjzxglMHPl9tO60ACJV6u9N+J3S8c=";
    };
    date = "2025-02-18";
  };
  rtw89 = {
    pname = "rtw89";
    version = "d1fced1b8a741dc9f92b47c69489c24385945f6e";
    src = fetchFromGitHub {
      owner = "lwfinger";
      repo = "rtw89";
      rev = "d1fced1b8a741dc9f92b47c69489c24385945f6e";
      fetchSubmodules = false;
      sha256 = "sha256-Htu1TihKkUCNWw5LCf+cnGyCQsj0PuijlfAolug2MC8=";
    };
    date = "2024-08-24";
  };
}
