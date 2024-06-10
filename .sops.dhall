let Prelude =
      https://prelude.dhall-lang.org/v22.0.0/package.dhall
        sha256:1c7622fdc868fe3a23462df3e6f533e50fdc12ecf3b42c0bb45c328ec8c4293e

let KeyGroups = List { age : List Text }

let CreationRule = { path_regex : Text, key_groups : KeyGroups }

let CreationRules = List CreationRule

let UserPrivilege = < Admin | Normal >

let User = { name : Text, privilege : UserPrivilege, key : Text }

let keys
    : List User
    = [ { name = "deodex"
        , privilege = UserPrivilege.Admin
        , key = "age1m3ffsvpmthzdekapjvh7eu8dfv8sce80w39v7npck7zyed65z46s4la6dz"
        }
      , { name = "ras"
        , privilege = UserPrivilege.Normal
        , key = "age1geq2hqhyyj58dt2ctt8mcy5c230n7kpe4tlunfmwxjzhx8gtee8qrzhfm3"
        }
      , { name = "chiffon"
        , privilege = UserPrivilege.Normal
        , key = "age13umf4p586fwud2jqe53jx7thxr0ezj224zwwrkan6fhe0cd8zsuqt8qp2c"
        }
      , { name = "salt"
        , privilege = UserPrivilege.Normal
        , key = "age104d6az72yr2wv2ur7ax8msugaxmhq5d3eftprwe44wy33xg7dv8sd04n2z"
        }
      , { name = "milk"
        , privilege = UserPrivilege.Normal
        , key = "age1l75e08kp97suhupp6hcqs4dawlm3dfqgevkjx4y54q3w5gjh6v3qm7sepa"
        }
      , { name = "shama"
        , privilege = UserPrivilege.Normal
        , key = "age1la3jf39atjz5tsvf05djcj63palt62w5ly03pzndecxeektw444q89jkx5"
        }
      , { name = "otohime"
        , privilege = UserPrivilege.Normal
        , key = "age155389m7zda44z28l962g4g8qjrlraf70dxp6vvfq2y7vk6ptg3xq5czrc6"
        }
      ]

let hasPrivilege =
      \(user : User) -> merge { Admin = True, Normal = False } user.privilege

let userSpecificRule
    : List User -> User -> CreationRule
    = \(keys : List User) ->
      \(user : User) ->
        { path_regex = "secrets/${user.name}\\.+\$"
        , key_groups =
          [ { age =
                  Prelude.List.map
                    User
                    Text
                    (\(user : User) -> user.key)
                    (Prelude.List.filter User hasPrivilege keys)
                # [ user.key ]
            }
          ]
        }

let creation_rules
    : CreationRules
    =   [ { path_regex = "secrets/secrets\\..+\$"
          , key_groups =
            [ { age =
                  Prelude.List.map User Text (\(user : User) -> user.key) keys
              }
            ]
          }
        ]
      # Prelude.List.map
          User
          CreationRule
          (userSpecificRule keys)
          ( Prelude.List.filter
              User
              ( Prelude.Function.compose
                  User
                  Bool
                  Bool
                  hasPrivilege
                  Prelude.Bool.not
              )
              keys
          )

in  { keys = Prelude.List.map User Text (\(user : User) -> user.key) keys
    , creation_rules
    }
