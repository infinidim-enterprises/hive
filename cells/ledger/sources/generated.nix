# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  ledgerblue = {
    pname = "ledgerblue";
    version = "117911c27993ee5a7e2e33e3a2181918941a27ef";
    src = fetchgit {
      url = "https://github.com/LedgerHQ/blue-loader-python";
      rev = "117911c27993ee5a7e2e33e3a2181918941a27ef";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-0fNuzulRa8uJMxMWPxJLvSkZLU3uk29DhauQDAi6Cvw=";
    };
    date = "2024-03-26";
  };
  python-gnupg = {
    pname = "python-gnupg";
    version = "0.5.2";
    src = fetchFromGitHub {
      owner = "vsajip";
      repo = "python-gnupg";
      rev = "0.5.2";
      fetchSubmodules = false;
      sha256 = "sha256-Z7kdPJ54CxvXWN1WJ9ywH4YsDJRdwvrapkXkDS26sFY=";
    };
  };
}
