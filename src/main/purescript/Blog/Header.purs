module Blog.Header
  ( Button(..)
  , buttons
  , Event(..)
  , Header(..)
  , render
  ) where

import Halogen (ComponentHTML)
import Halogen.HTML (className)
import Prelude

import Halogen.HTML.Events.Indexed               as E
import Halogen.HTML.Indexed                      as H
import Halogen.HTML.Properties.Indexed           as P

searchPlaceholder :: String
searchPlaceholder = "Search for posts"

newtype Button = Button { name :: String }
derive instance eqButton :: Eq Button

data Event a
    = Clicked Button a
    | NewSearchTerms String a

data Header a
    = Selected Button a
    | SearchTerms String a

classes :: forall r i. Array String -> P.IProp (class :: P.I | r) i
classes = P.classes <<< map className

isActive :: forall a. Header a -> Button -> Boolean
isActive (Selected selected _) button | button == selected = true
isActive _ _ = false

searchBarText :: forall a. Header a -> String
searchBarText (SearchTerms searchTerms _) = searchTerms
searchBarText _ = ""

render :: forall a. Header a -> ComponentHTML Event
render header =
    H.nav [classes ["row", "navbar", "navbar-default"]] [
        H.div [classes ["navbar-header"]] [
            H.ul [classes ["nav", "navbar-nav"]]
                (map (\button -> renderButton button (isActive header button)) buttons) 
        ],

        H.div [classes ["navbar-form"]] [
            -- TODO: Add these inline styles
            H.div [classes ["form-group"]{-, style [("display", "inline")]-}] [
                H.div [classes ["input-group"]{-, style [("display", "table")]-}] [
                    H.span [classes ["input-group-addon"]{-, style [("width", "1%")]-}] [
                        H.span [classes ["glyphicon", "glyphicon-search"]] []
                    ],

                    H.input [
                        classes ["form-control"],
                        E.onValueInput (E.input NewSearchTerms),
                        P.inputType P.InputText,
                        P.value (searchBarText header),
                        P.placeholder searchPlaceholder
                    ]
                ]
            ]
        ]
    ]

renderButton :: Button -> Boolean -> ComponentHTML Event
renderButton button@(Button { name }) isActive =
    if isActive then
        H.li [classes ["active"]] [
           H.a_ [
                H.text name
           ]
        ]
    else
        H.li_ [
            H.a [E.onClick (E.input_ (Clicked button))] [
                H.text name
            ]
        ]

postsButton :: Button
postsButton = Button { name: "Posts" }

tagsButton :: Button
tagsButton  = Button { name: "Tags" }

aboutButton :: Button
aboutButton = Button { name: "About" }

buttons :: Array Button
buttons = [postsButton, tagsButton, aboutButton]
