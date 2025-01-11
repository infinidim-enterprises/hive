#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages (p: [p.mmh3])"

import mmh3
import json
import sys

if len(sys.argv) != 2:
    print("Usage: iaid.py <input_string>")
    sys.exit(1)

hex_value = f"{mmh3.hash(sys.argv[1]) & 0xFFFFFFFF:08x}"
print(json.dumps({"iaid": hex_value}))
