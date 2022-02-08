let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.20-20220131/package-set.dhall sha256:5d3cc1e3be83d178f0e2210998f8266e536ebd241f415df8e87feb53effe6254
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  -- This is where you can add your own packages to the package-set
  additions =
    [{ name = "principal"
      , repo = "https://github.com/aviate-labs/principal.mo"
      , version = "v0.2.3"
      , dependencies = [ "array", "base", "encoding", "hash", "sha" ]
      },
          { name = "hash"
      , repo = "https://github.com/aviate-labs/hash.mo"
      , version = "v0.1.0"
      , dependencies = [ "array", "base" ]
      },{ name = "array"
      , repo = "https://github.com/aviate-labs/array.mo"
      , version = "v0.1.1"
      , dependencies = [ "base" ]
      },{ name = "encoding"
      , repo = "https://github.com/aviate-labs/encoding.mo"
      , version = "v0.3.1"
      , dependencies = [ "array", "base" ]
      },
      { name = "sha"
      , repo = "https://github.com/aviate-labs/sha.mo"
      , version = "v0.1.1"
      , dependencies = [ "base", "encoding" ]
      },
      { name = "ext"
      , repo = "https://github.com/aviate-labs/ext.std"
      , version = "v0.2.0"
      , dependencies = [ "array", "base", "encoding", "principal", "sha" ]
      },
      { name = "cap"
      , repo = "https://github.com/Psychedelic/cap-motoko-library"
      , version = "v1.0.4"
      , dependencies = [] : List Text
      }] : List Package

let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"z
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [] : List Package

in  upstream # additions # overrides
