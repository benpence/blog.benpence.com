module Main where
import Prelude

import Text.Smolder.HTML as H
import Text.Smolder.Markup ((!), text)
import Text.Smolder.HTML.Attributes as A

import Color (black, toHexString)

import Flare.Smolder (runFlareHTML)
import Flare

main = runFlareHTML "controls" "output" ui

-- This is the full user interface definition:
ui = markup <$> string    "Title"     "Try Flare!"
            <*> color     "Color"     black
            <*> intSlider "Font size" 5 50 26
            <*> boolean   "Italic"    false


markup title color fontSize italic = do
  H.h1 ! A.style ("color: " <> toHexString color <> ";" <>
                  "font-size: " <> show fontSize <> "px;" <>
                  "font-style: " <> if italic then "italic" else "normal")
       $ (text title)

  H.p $ text "The Flare library allows you to quickly create reactive web interfaces like the one above."
  H.p $ text $ "You can change the PureScript code in the editor on the left. " <>
                 "For example, try to replace 'intSlider' by 'intRange'. " <>
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
