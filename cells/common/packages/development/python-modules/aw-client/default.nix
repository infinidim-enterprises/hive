{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, poetry
, aw-core
, requests
, persist-queue
, click
, tabulate
, pytest
}:

buildPythonPackage rec {
  pname = "aw-client";
  version = "0.5.9";

  format = "pyproject";

  # pypi distribution doesn't include tests, so build from source instead
  src = fetchFromGitHub {
    owner = "ActivityWatch";
    repo = "aw-client";
    rev = "v${version}";
    sha256 = "sha256-w100S22ugAo3gldJDYskzJNOxvJRFMw++J5B+6/6sfI=";
  };

  disabled = pythonOlder "3.8";

  nativeBuildInputs = [
    poetry
  ];

  propagatedBuildInputs = [
    aw-core
    requests
    persist-queue
    click
    tabulate
  ];

  checkInputs = [ pytest ];
  checkPhase = ''
    runHook preCheck

    # Fake home folder for tests that write to $HOME
    export HOME="$TMP/fake-test-home"
    pytest tests/test_requestqueue.py

    runHook postCheck
  '';
  pythonImportsCheck = [ "aw_client" ];

  meta = with lib; {
    description = "Client library for ActivityWatch";
    homepage = "https://github.com/ActivityWatch/aw-client";
    maintainers = with maintainers; [ jtojnar ];
    license = licenses.mpl20;
  };
}
