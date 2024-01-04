{ sources
, haskellPackages
}:
haskellPackages.callCabal2nix "dbus-listen" sources.dbus-listen.src { }
