module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)

import Control.Monad.Eff.Console        as Console

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
    Console.log ("Hello sailor!" <> "HELELEL")
