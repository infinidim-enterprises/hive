{ langchain, python3Packages, fetchurl, sources }:
with python3Packages;
python3Packages.buildPythonPackage rec {
  inherit (sources.chatgpt-wrapper) pname version src;

  propagatedBuildInputs = with python3Packages; [
    playwright
    gnureadline
    rich
    pyyaml
    sqlalchemy
    python-frontmatter
    tiktoken
    jinja2
    names
    pyperclip
    email-validator
    prompt-toolkit

    langchain
  ];
  doCheck = false;
}
