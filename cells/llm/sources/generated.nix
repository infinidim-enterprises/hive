# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  aider-chat = {
    pname = "aider-chat";
    version = "v0.77.0";
    src = fetchFromGitHub {
      owner = "Aider-AI";
      repo = "aider";
      rev = "v0.77.0";
      fetchSubmodules = false;
      sha256 = "sha256-wGVkcccTNhNbAWhWwpprNrXOm7u1R7qtiPTT5Lqidkg=";
    };
  };
  gluetun = {
    pname = "gluetun";
    version = "latest";
    src = dockerTools.pullImage {
      imageName = "qmcgaw/gluetun";
      imageDigest = "sha256:183c74263a07f4c931979140ac99ff4fbc44dcb1ca5b055856ef580b0fafdf1c";
      sha256 = "sha256-pwLX41ulCmZi0F4hbUTlZCG7tSUYez5LPl2Mg2ecbcw=";
      finalImageTag = "latest";
      os = "linux";
      arch = "amd64";
    };
  };
  lobe-chat = {
    pname = "lobe-chat";
    version = "latest";
    src = dockerTools.pullImage {
      imageName = "lobehub/lobe-chat";
      imageDigest = "sha256:d27484d7c858ec2b1d553851f332a7543c3affed5dc4b2aa2af695f4c26f587e";
      sha256 = "sha256-gGWc3Pk8sTa3FnwXns9pg2QqMAb1ARrXuB5Z1pUKRu8=";
      finalImageTag = "latest";
      os = "linux";
      arch = "amd64";
    };
  };
  n8n = {
    pname = "n8n";
    version = "n8n@1.82.3";
    src = fetchurl {
      url = "https://github.com/n8n-io/n8n/archive/n8n@1.82.3.tar.gz";
      name = "n8n.tar.gz";
      sha256 = "sha256-QAMpbI3xdFnly+pkwlZP6jB+cSxgmxCgqVpl6z/b2DY=";
    };
  };
}
