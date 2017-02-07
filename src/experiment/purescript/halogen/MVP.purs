module Main where

import Control.Monad.Eff
import Halogen.Driver
import Halogen.Effects
import Halogen.Query
import Halogen.Util
import Prelude
import Halogen (ComponentDSL, ComponentHTML, Component, component, gets, modify)
import Halogen.HTML.Indexed as H
import Halogen.HTML.Events.Indexed as E

-- | The state of the component
type State = { count :: Int }

-- | The query algebra for the component
data Query a
  = Increment a
  | Decrement a
  | GetState (Int -> a)

-- | The component definition
myComponent :: forall g. Component State Query g
myComponent = component { render, eval }
  where

  render :: State -> ComponentHTML Query
  render state =
    H.div_
      [ H.h1_
          [ H.text "Count" ]
      , [ H.text (show state.count) ]
      , H.button
          [ E.onClick (E.input_ Increment) ]
          [ H.text "+" ]
      , H.button
          [ E.onClick (E.input_ Decrement) ]
          [ H.text "-" ]
      ]

  eval :: Query ~> ComponentDSL State Query g
  eval (Increment next) = do
    modify (\state -> state { count = (state.count + 1) })
    pure next
  eval (Decrement next) = do
    modify (\state -> state { count = (state.count - 1) })
    pure next
  eval (GetState continue) = do
    value <- gets _.count
    pure (continue value)

initialState :: State
initialState = { count: 0 }

main :: Eff (HalogenEffects ()) Unit
main = runHalogenAff do
  body <- awaitBody
  runUI myComponent initialState body
