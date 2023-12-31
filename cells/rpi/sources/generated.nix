# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  libcamera = {
    pname = "libcamera";
    version = "563cd78e1c9858769f7e4cc2628e2515836fd6e7";
    src = fetchFromGitHub {
      owner = "raspberrypi";
      repo = "libcamera";
      rev = "563cd78e1c9858769f7e4cc2628e2515836fd6e7";
      fetchSubmodules = false;
      sha256 = "sha256-T5MBTTYaDfaWEo/czTE822e5ZXQmcJ9pd+RWNoM4sBs=";
    };
    date = "2023-11-22";
  };
  libcamera-apps = {
    pname = "libcamera-apps";
    version = "b6ee44031edd2c83094c48793973cf0f24b2ba00";
    src = fetchFromGitHub {
      owner = "raspberrypi";
      repo = "libcamera-apps";
      rev = "b6ee44031edd2c83094c48793973cf0f24b2ba00";
      fetchSubmodules = false;
      sha256 = "sha256-WjIGVvOb5EFaXNsNzUcE8SXT2r2lmVWxlUfJFaCDMuE=";
    };
    date = "2023-11-30";
  };
  mediamtx = {
    pname = "mediamtx";
    version = "3e12f837325888f1ac5c2de9fbcf593a434a4fb7";
    src = fetchFromGitHub {
      owner = "bluenviron";
      repo = "mediamtx";
      rev = "3e12f837325888f1ac5c2de9fbcf593a434a4fb7";
      fetchSubmodules = false;
      sha256 = "sha256-iwTkHwM8DQI0oDfczOPnVC9vqRUB+gU3x9T19MB7lcA=";
    };
    date = "2023-12-01";
  };
}
