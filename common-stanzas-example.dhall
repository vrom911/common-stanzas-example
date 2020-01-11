let prelude = https://raw.githubusercontent.com/dhall-lang/dhall-to-cabal/1.3.4.0/dhall/prelude.dhall
let types = https://raw.githubusercontent.com/dhall-lang/dhall-to-cabal/1.3.4.0/dhall/types.dhall

----------------------------------------------------------------------------
-- Common parts
----------------------------------------------------------------------------

let base =
    { package = "base"
    , bounds = prelude.majorBoundVersion (prelude.v "4.13.0.0")
    }

let common-stanzas-example =
    { package = "common-stanzas-example-dhall"
    , bounds = prelude.anyVersion
    }

let common-options =
    { compiler-options = prelude.defaults.CompilerOptions //
        { GHC =
            [ "-Wall"
            , "-Wincomplete-uni-patterns"
            , "-Wincomplete-record-updates"
            , "-Wcompat"
            , "-Widentities"
            , "-Wredundant-constraints"
            , "-fhide-source-paths"
            , "-Wmissing-export-lists"
            , "-Wpartial-fields"
            , "-Wmissing-deriving-strategies"
            ] : List Text
        }

    , default-extensions =
        [ types.Extension.ConstraintKinds True
        , types.Extension.DeriveGeneric True
        , types.Extension.GeneralizedNewtypeDeriving True
        , types.Extension.InstanceSigs True
        , types.Extension.KindSignatures True
        , types.Extension.LambdaCase True
        , types.Extension.OverloadedStrings True
        , types.Extension.RecordWildCards True
        , types.Extension.ScopedTypeVariables True
        , types.Extension.StandaloneDeriving True
        , types.Extension.TupleSections True
        , types.Extension.TypeApplications True
        , types.Extension.ViewPatterns True
        ]
    , default-language = Some types.Language.Haskell2010
    }

let executable-ghc-options = prelude.defaults.CompilerOptions //
    { GHC = common-options.compiler-options.GHC #
        [ "-threaded"
        , "-rtsopts"
        , "-with-rtsopts=-N"
        ] : List Text
    }

let common-tests = common-options //
    { hs-source-dirs = [ "test" ]
    , build-depends =
         [ base
         , common-stanzas-example
         , { package = "hedgehog"
           , bounds = prelude.majorBoundVersion (prelude.v "1.0")
           }
         , { package = "hspec"
           , bounds = prelude.majorBoundVersion (prelude.v "2.7.1")
           }
         ]
    , compiler-options = executable-ghc-options
    }

----------------------------------------------------------------------------
-- General package information
----------------------------------------------------------------------------

in prelude.defaults.Package //
    { cabal-version = prelude.v "2.2"
    , name = "common-stanzas-example-dhall"
    , version = prelude.v "0.0.0.0"
    , synopsis = "Example project to demonstrate the common stanzas feature"
    , description = "Example project to demonstrate the common stanzas feature"
    , homepage = "https://github.com/vrom911/common-stanzas-example"
    , bug-reports = "https://github.com/vrom911/common-stanzas-example/issues"
    , license = types.License.SPDX ( prelude.SPDX.license types.LicenseId.MPL_2_0 (None types.LicenseExceptionId))
    , license-files = [ "LICENSE" ]
    , author = "Veronika Romashkina"
    , maintainer = "Veronika Romashkina <vrom911@gmail.com>"
    , copyright = "2020 Veronika Romashkina"
    , category = "Example"
    , build-type = Some types.BuildType.Simple
    , extra-doc-files = [ "README.md", "CHANGELOG.md" ]
    , tested-with =
        [ { compiler = types.Compiler.GHC
          , version = prelude.thisVersion (prelude.v "8.8.1")
          }
        ]

----------------------------------------------------------------------------
-- Source repository set up
----------------------------------------------------------------------------

    , source-repos =
        [ prelude.defaults.SourceRepo //
            { type = Some types.RepoType.Git
            , location = Some "https://github.com/vrom911/common-stanzas-example.git"
            }
        ]

----------------------------------------------------------------------------
-- Library stanza
----------------------------------------------------------------------------

    , library = Some
        ( λ(config : types.Config) →
        prelude.defaults.Library // common-options //
            { build-depends = [ base ]
            , hs-source-dirs = [ "src" ]
            , exposed-modules = [ "CommonStanzasExample" ]
            }
        )

----------------------------------------------------------------------------
-- Executable stanza
----------------------------------------------------------------------------

    , executables =
        [ { name = "common-stanzas-example"
          , executable = λ(config : types.Config) →
            prelude.defaults.Executable // common-options //
                { hs-source-dirs = [ "app" ]
                , main-is = "Main.hs"
                , build-depends =
                    [ base
                    , common-stanzas-example
                    ]
                , compiler-options = executable-ghc-options
                }
          }
        ]

    , test-suites =

----------------------------------------------------------------------------
-- Test suite # 1
----------------------------------------------------------------------------

        [ { name = "test-suite-1"
          , test-suite = λ(config : types.Config) →
            prelude.defaults.TestSuite // common-tests //
                { type = types.TestType.exitcode-stdio { main-is = "Spec1.hs" }
                , hs-source-dirs = [ "test" ]
                }
          }

----------------------------------------------------------------------------
-- Test suite # 2
----------------------------------------------------------------------------

        , { name = "test-suite-2"
          , test-suite = λ(config : types.Config) →
            prelude.defaults.TestSuite // common-tests //
                { type = types.TestType.exitcode-stdio { main-is = "Spec2.hs" }
                , hs-source-dirs = [ "test" ]
                }
          }
        ]
    }
