module Blog.TagCounts
  ( Action(..)
  , State
  , init
  , update
  , view
  ) where

import Blog.Types (Tag, TagCount)
import Pux.Html (Html)
import Prelude

import Data.Array                                as Array
import Pux.Html                                  as H
import Pux.Html.Attributes                       as A
import Pux.Html.Events                           as E

data Action
    = Clicked Tag

type State =
    { tagCounts :: Array TagCount
    }

init :: Array TagCount -> State
init tagCounts = { tagCounts }

update :: Action -> State -> State
update (Clicked tag) state = state

view :: State -> Html Action
view state =
    H.div [A.className "tag-list list-group"] (
        map viewTagCount (Array.sortBy (comparing _.tag.name) state.tagCounts)
    )

viewTagCount :: TagCount -> Html Action
viewTagCount tagCount =
  let
    attributes =
        [ E.onClick (const (Clicked tagCount.tag))
        , A.className "tag-count list-group-item"
        ]

    tagCountString = tagCount.tag.name <> " (" <> show tagCount.count <> ")"
  in
    H.button attributes [H.text tagCountString]
