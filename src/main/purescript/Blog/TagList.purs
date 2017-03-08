module Blog.TagList
  ( Action(..)
  , State
  , init
  , update
  , view
  ) where

import Blog.Types (Tag)
import Pux.Html (Html)
import Prelude

import Pux.Html                                  as H
import Pux.Html.Attributes                       as A
import Pux.Html.Events                           as E

data Action
    = Clicked Tag

type State
    = { tags :: Array Tag
      }

init :: Array Tag -> State
init tags = { tags: tags }

update :: Action -> State -> State
update (Clicked tag) state = state

view :: State -> Html Action
view state =
    H.span [A.className "post-tags"] (map renderButton state.tags)

renderButton :: Tag -> Html Action
renderButton tag =
  let
    attrs =
        [ A.className "post-tag"
        , A.className "btn"
        , A.className "btn-default"
        , A.className "btn-xs"
        , E.onClick (const (Clicked tag))
        ]
  in
    H.a attrs [H.text tag.name]
