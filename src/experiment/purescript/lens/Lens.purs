module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Data.Array
import Data.Traversable
import Optic.Core
import Optic.Lens
import Optic.Setter
import Optic.Types
import Optic.Getter

import Control.Monad.Eff.Console        as Console
import Data.Array                       as Array

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
    Console.log (view name (set name "Ben Pence" bill))

bill :: Person
bill = { name: "Bill Parker" }

jean :: Person
jean = { name: "Jean Parker" }

parkers :: Family
parkers = { people: [bill, jean] }

type Person = { name :: String }
type Family = { people :: Array Person }
type Community = { families :: Array Family }

name :: Lens' Person String
name = lens _.name (_ { name = _ })

people :: Lens' Family (Array Person)
people = lens _.people (_ { people = _})
