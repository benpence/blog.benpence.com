module Blog.TagList
  ( component
  , Query(..)
  , State
  ) where

import Blog (Tag)
import Data.Maybe (Maybe(..))
import Halogen (Component, ComponentDSL, ComponentHTML)
import Prelude

import Halogen                                   as Halogen
import Halogen.HTML.Events.Indexed               as E
import Halogen.HTML.Indexed                      as H
import Halogen.HTML.Properties.Indexed           as P

data Query a
    = Clicked Tag a

type State
    = { tags :: Array Tag
      }

initialState :: Array Tag -> State
initialState tags = { tags: tags }

component :: forall g. Component State Query g
component = Halogen.component { render, eval }

eval :: forall g. Query ~> ComponentDSL State Query g
eval (Clicked tag next) = do
    pure next

render :: State -> ComponentHTML Query
render state =
    H.span [P.class_ (H.className "post-tags")] (map renderButton state.tags)

renderButton :: Tag -> ComponentHTML Query
renderButton tag =
    H.a [classes, E.onClick (E.input_ (Clicked tag))] [
        H.text tag.name
    ]
  where
    classes = P.classes [
        H.className "post-tag",
        H.className "btn",
        H.className "btn-default",
        H.className "btn-xs"
    ]
