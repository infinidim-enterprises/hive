{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, poetry
, jsonschema
, peewee
, appdirs
, iso8601
, rfc3339-validator
, TakeTheTime
, strict-rfc3339
, tomlkit
, deprecation
, timeslot
  # , pymongo
, python-json-logger
, pytest
}:

buildPythonPackage rec {
  pname = "aw-core";
  version = "0.5.10";

  format = "pyproject";

  # pypi distribution doesn't include tests, so build from source instead
  src = fetchFromGitHub {
    owner = "ActivityWatch";
    repo = "aw-core";
    rev = "v${version}";
    sha256 = "sha256-fXyWf1Zu3bavpdYE1I5awV0XcFPSky3SPhhjfvcHc8s=";
  };

  disabled = pythonOlder "3.8";

  nativeBuildInputs = [
    poetry
  ];

  # pymongo is an optional, linux-only dependency
  # However, aw-core expects an older version than nixpkgs uses
  propagatedBuildInputs = [
    jsonschema
    peewee
    appdirs
    iso8601
    rfc3339-validator
    TakeTheTime
    strict-rfc3339
    tomlkit
    deprecation
    timeslot
    # pymongo
    python-json-logger
  ];

  checkInputs = [ pytest ];
  checkPhase = ''
    runHook preCheck

    # Fake home folder for tests that write to $HOME
    export HOME="$TMP/fake-test-home"
    pytest tests/

    runHook postCheck
  '';

  meta = with lib; {
    description = "Core library for ActivityWatch";
    homepage = "https://github.com/ActivityWatch/aw-core";
    maintainers = with maintainers; [ jtojnar ];
    license = licenses.mpl20;
  };
}
