module Blog.Tag
  ( Event(..)
  , Tag
  , renderButtons
  , renderCounts
  ) where

import Data.Tuple (Tuple(..))
import Halogen (ComponentHTML)
import Prelude

import Data.Array                                as Array
import Halogen.HTML.Events.Indexed               as E
import Halogen.HTML.Indexed                      as H
import Halogen.HTML.Properties.Indexed           as P
import Data.Tuple                                as Tuple

type Tag = { name :: String }

data Event a = Clicked Tag a

renderButtons :: Array Tag -> ComponentHTML Event
renderButtons tags =
    H.span [P.class_ (H.className "post-tags")] (map renderButton tags)

renderButton :: Tag -> ComponentHTML Event
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

renderCounts :: Array (Tuple Tag Int) -> ComponentHTML Event
renderCounts tagCounts =
    H.div [P.classes [H.className "tag-list", H.className "list-group"]] (
        map renderCount (Array.sortBy (comparing (_.name <<< Tuple.fst)) tagCounts)
    )

renderCount :: (Tuple Tag Int) -> (ComponentHTML Event)
renderCount (Tuple tag count) =
    H.button [E.onClick (E.input_ (Clicked tag)), P.classes [H.className "tag-count", H.className "list-group-item"]] [
        H.text (tag.name <> " (" <> show count <> ")")
    ]
