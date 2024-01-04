{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, pytest
, pytest-cov
}:

buildPythonPackage rec {
  pname = "timeslot";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "oqyZhlfj87nKkodXtJBq3SwFOQxfwU7XkruQKNCFR7E=";
  };

  disabled = pythonOlder "3.6";

  # Tests not included on pypi, disable it for now.
  doCheck = false;
  checkInputs = [ pytest pytest-cov ];
  checkPhase = ''
    runHook preCheck

    pytest

    runHook postCheck
  '';

  meta = with lib; {
    description = "Data type for representing time slots with a start and end";
    homepage = "https://github.com/ErikBjare/timeslot";
    maintainers = with maintainers; [ jtojnar ];
    license = licenses.mit;
  };
}
