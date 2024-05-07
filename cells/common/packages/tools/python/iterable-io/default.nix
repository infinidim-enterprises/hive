{ buildPythonPackage, setuptools, sources }:

buildPythonPackage {
  inherit (sources.iterable-io) src pname version;
  format = "pyproject";
  nativeBuildInputs = [ setuptools ];
}
