module Blog.TagCounts
  ( component
  , Query(..)
  ) where

import Blog.Tag (Tag)
import Data.Maybe (Maybe(..))
import Halogen (Component, ComponentDSL, ComponentHTML)
import Prelude

import Data.Array                                as Array
import Halogen                                   as Halogen
import Halogen.HTML.Events.Indexed               as E
import Halogen.HTML.Indexed                      as H
import Halogen.HTML.Properties.Indexed           as P

type TagCount = { tag :: Tag, count :: Int }

data Query a
    = Clicked Tag a
    | GetSelected (Maybe Tag -> a)

type State
    = { tagCounts :: Array TagCount
      -- Tells parent to change
      , selected :: Maybe Tag
      }

initialState :: Array TagCount -> State
initialState tagCounts = { tagCounts, selected: Nothing }

component :: forall g. Component State Query g
component = Halogen.component { render, eval }

eval :: forall g. Query ~> ComponentDSL State Query g
eval (Clicked tag next) = do
  Halogen.modify (\state -> state { selected = Just tag })
  -- TODO: Access API and emit event
  pure next
eval (GetSelected continue) = do
    selected <- Halogen.gets _.selected
    pure (continue selected)

render :: State -> ComponentHTML Query
render state =
    H.div [P.classes [H.className "tag-list", H.className "list-group"]] (
        map renderTagCount (Array.sortBy (comparing _.tag.name) state.tagCounts)
    )

renderTagCount :: TagCount -> (ComponentHTML Query)
renderTagCount tagCount =
  let
    attributes =
        [ E.onClick (E.input_ (Clicked tagCount.tag))
        , P.classes [H.className "tag-count", H.className "list-group-item"]
        ]
  in
    H.button attributes [H.text (tagCount.tag.name <> " (" <> show tagCount.count <> ")")]
