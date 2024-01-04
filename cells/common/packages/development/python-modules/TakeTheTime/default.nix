{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, nose
}:

buildPythonPackage rec {
  pname = "TakeTheTime";
  version = "0.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "2+MEU6G1lqOPni4/qOGtxa8tv2RsoIN61cIFmhb+L/k=";
  };

  disabled = pythonOlder "3.6";

  # Tests not included on pypi, disable it for now.
  doCheck = false;
  checkInputs = [ nose ];
  checkPhase = ''
    runHook preCheck

    nosetests -v tests/

    runHook postCheck
  '';

  meta = with lib; {
    description = "Simple time taking library using context managers";
    homepage = "https://github.com/ErikBjare/TakeTheTime";
    maintainers = with maintainers; [ jtojnar ];
    license = licenses.mit;
  };
}
