{ lib, cell, inputs, ... }:
let
  packages = {
    __functor = _self:
      { src
      , skip ? [ ]
      , nixpkgs ? inputs.nixpkgs-unstable
      , system ? inputs.nixpkgs.system
      , overlays ? [ ]
      , extraArguments ? { }
      , ...
      }:

        with (lib // builtins);

        let
          inherit (inputs) haumea;
          inherit (cell.lib) filterPath;

          tracer = cursor: path:
            # trace "cursor length ${toString (length cursor)} || cursor is ${concatStringsSep "->" cursor} " path;
            traceSeq "Debugging" { cursor = cursor; path = path; };
          # if dir ? default
          # then { dir = dir.default; }
          # else dir;

          t2 = cursor: path:
            if cursor != [ ] && path ? "${last cursor}"
            then path
            else { "${last cursor}" = path.default; };

          t3 = cursor: path:
            if cursor != [ ] && path ? "${last cursor}"
            then { "${last cursor}" = path.default; }
            else { }; # { "${last cursor}" = dir.default; };

          t4 = cursor: path:
            let
              result =
                if path ? default
                then {
                  key = last cursor;
                  value = path.default;
                }
                else null;
            in
            optionalAttrs (result != null) {
              ${result.key} = result.value;
            };

          t5 = cursor: path:
            let
              # debug = cursor: path: lib.traceSeq "Debugging" { cursor = cursor; path = path; };
              # _ = debug cursor path;

              isDefaultNixPath = path: path ? default;
              extractKey = cursor:
                if length cursor > 0
                then last cursor
                else null;

              key = extractKey cursor;
              value =
                if isDefaultNixPath path
                then path
                else null;
            in
            # Only include entries where there's a meaningful key and the path indicates a default.nix file
            optionalAttrs (key != null && value != null)
              {
                ${key} = value;
              };

          t6 = cursor: path:
            let
              extractDeepest = path:
                let
                  go = prevKey: value:
                    if lib.isAttrs value
                    then
                      lib.foldl'
                        (acc: key:
                          let newValue = value.${key}; in
                          go key newValue)
                        { inherit prevKey; }
                        (lib.attrNames value)
                    else { key = prevKey; value = value; };
                in
                go null path;

              deepest = extractDeepest path;
            in
            { };

          t7 = cursor: path:
            if length cursor > 0 && path ? "default"
            then { ${last cursor} = path.default; }
            else { };

          t8 = cursor: path:
            let
              # Check if we're at a point where 'default' can be extracted
              canExtractDefault = lib.length cursor > 0 && path ? "default";
              # Extract the key from the last element of the cursor, if applicable
              key =
                if canExtractDefault
                then lib.last cursor
                else null;
              # Prepare the value associated with 'key', if conditions are met
              value =
                if canExtractDefault
                then path.default
                else null;
            in
            # If conditions are met, return the updated attribute set; otherwise, pass 'path' through
            if canExtractDefault
            then { ${key} = value; }
            else path;

          t9 = cursor: path:
            let
              # Function to progressively trim 'path' from the left based on the cursor position.
              trimPath = { currentPath, currentIndex }:
                if currentIndex < lib.length cursor
                then
                  let
                    # Correctly access the next key in the cursor list
                    nextKey = lib.elemAt cursor currentIndex;
                    # Dive one level deeper into 'currentPath' if possible, using the next key
                    nextPath = currentPath.${nextKey} or { };
                  in
                  # Recursively call trimPath with the updated path and index
                  trimPath { currentPath = nextPath; currentIndex = currentIndex + 1; }
                else
                # Once we've processed all elements in the cursor, return the currentPath
                  currentPath;

              # Apply trimPath starting from the current path and index 0
              trimmedPath = trimPath { currentPath = path; currentIndex = 0; };

              # Construct the result if the trimmed path contains 'default.nix'
              result =
                if trimmedPath ? "default" then
                  let
                    # Use the last element of the cursor as the key for the output attribute set
                    key = lib.last cursor;
                    # The value is the path to 'default.nix' within the trimmed path
                    value = trimmedPath.default;
                  in
                  # Return an attribute set with the directory name containing 'default.nix' as the key
                  { ${key} = value; }
                else
                # If no 'default.nix' is found in the trimmed path, return an empty set
                  trimmedPath;

            in
            result;

          # t1 = cursor: dir:
          #   if (builtins.length cursor == 0 && (dir ? default))
          #   then removeAttrs dir [ "default" ]
          #   else dir;

          pkgs = import nixpkgs {
            inherit overlays system;
            allowUnfree = true;
          };
        in

        haumea.lib.load {
          src = filterPath { inherit skip src; };
          loader = haumea.lib.loaders.path;
          transformer = with cell.lib.haumea.transformers;
            [
              t9
              # raiseDefault
              # (callPackage { inherit pkgs extraArguments; })
            ];
        };

    # TODO: doc
    doc = ''
      packages
    '';
  };
in
packages
