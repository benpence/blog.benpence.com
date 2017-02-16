module Blog.TagCounts
  ( Event(..)
  , render
  ) where

import Prelude

import DOM (DOM)
import Color (black, toHexString)
import Signal.Channel (CHANNEL)
import Text.Smolder.Markup ((!), text)

import Control.Monad.Eff (Eff)
import Data.Traversable                          as Traversable
import Flare                                     as Flare
import Flare.Smolder                             as Smolder
import Text.Smolder.HTML                         as H
import Text.Smolder.HTML.Attributes              as A

data Event
    = Clicked Tag

-- This is the full user interface definition:
render :: forall e . Array TagCount -> UI e Event
render tagCounts = do
  let
    sortedTags = Array.sortBy (comparing _.tag.name) tagCounts
  in
    H.div Traversable.foldMap renderTagCount 
        `H.with` A.className "tag-list"
        `H.with` A.className "list-group"

renderTagCount :: forall e . TagCount -> UI e Tag
renderTagCount tagCount
  let
    attributes =
        [ E.onClick (E.input_ (Clicked tagCount.tag))
        , P.classes [H.className "tag-count", H.className "list-group-item"]
        ]
  in
    H.button attributes [H.text (tagCount.tag.name <> " (" <> show tagCount.count <> ")")]

    markup <$> Flare.string    "Title"     "Try Flare!"
           <*> Flare.color     "Color"     black
           <*> Flare.intSlider "Font size" 5 50 26
           <*> Flare.boolean   "Italic"    false


markup title color fontSize italic = do
  H.h1 ! A.style ("Flare.color: " <> toHexString color <> ";" <>
                  "font-size: " <> show fontSize <> "px;" <>
                  "font-style: " <> if italic then "italic" else "normal")
       $ (text title)

  H.p $ text "The Flare library allows you to quickly create reactive web interfaces like the one above."
  H.p $ text $ "You can change the PureScript code in the editor on the left. " <>
                 "For example, try to replace 'Flare.intSlider' by 'intRange'. " <>
                 "For something more challenging, try to add a slider to control the x-position ('margin-left') of the message."
  H.p $ do
    text "For help, see the "
    H.a ! A.href "http://pursuit.purescript.org/packages/purescript-flare/"
        ! A.target "top"
            $ text "Flare module documentation."


  H.h2 $ text "Examples"
  H.p $ text "Look at more code examples below, or create your own!"
  H.ul $ do
    example "Basic Flare UI" "3f467239e50a516a7a17"
    example "Maintaining state: A counter" "cbc3896505769e367779"
    example "Radio groups: Temperature conversion" "4dda75028367a04440b7"
    example "Multiple buttons" "7cc18f15e869c67da984"
    example "Time dependence: Incremental game" "6ab3ee1c9aa532ed5b5c"
    example "Simple Drawing example" "e4506e5991523e30f8cb"
    example "Simple HTML example" "67a8544640a9900d43ac"
    example "Interactive animation" "c579fcec1a1ce53367cc"
  H.p $ text "FlareCheck examples"
  H.ul $ do
    example "Basic example" "1b115f1135bc2fb6e643"

  where
    example name gist = H.li $ H.a ! A.href ("?gist=" <> gist <> "&backend=flare")
                                   ! A.target "top"
                                   $ text name
