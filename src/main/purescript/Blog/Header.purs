module Blog.Header
  ( Action(..)
  , Button(..)
  , State
  , buttons
  , init
  , update
  , view
  ) where

import Data.Tuple (Tuple(..))
import Pux.Html (Html)
import Prelude

import Pux.Html                                  as H
import Pux.Html.Attributes                       as A
import Pux.Html.Events                           as E

newtype Button = Button { name :: String }
derive instance eqButton :: Eq Button
derive instance ordButton :: Ord Button

data Action
    = Clicked Button
    | NewSearchTerms String

data State
    = Selected Button
    | SearchTerms String

init :: State
init = Selected postsButton

postsButton :: Button
postsButton = Button { name: "Posts" }

tagsButton :: Button
tagsButton  = Button { name: "Tags" }

aboutButton :: Button
aboutButton = Button { name: "About" }

buttons :: Array Button
buttons = [postsButton, tagsButton, aboutButton]

searchPlaceholder :: String
searchPlaceholder = "Search for posts"

update :: Action -> State -> State
update (Clicked button) _ = Selected button
update (NewSearchTerms searchTerms) _ =
    if searchTerms == ""
    then init
    else SearchTerms searchTerms

view :: State -> Html Action
view header =
    H.nav [A.className "row", A.className "navbar", A.className "navbar-default"] [
        H.div [A.className "navbar-header"] [
            H.ul [A.className "nav", A.className "navbar-nav"] (map (\button ->
                viewButton button (isActive header button))
            buttons) 
        ],

        H.div [A.className "navbar-form"] [
            H.div [A.className "form-group", A.style [Tuple "display" "inline"]] [
                H.div [A.className "input-group", A.style [Tuple "display" "table"]] [
                    H.span [A.className "input-group-addon", A.style [Tuple "width" "1%"]] [
                        H.span [A.className "glyphicon", A.className "glyphicon-search"] []
                    ],

                    H.input [
                        A.type_ "text",
                        A.className "form-control",
                        A.value (searchBarText header),
                        E.onChange (NewSearchTerms <<< _.target.value)
                    ] []
                ]
            ]
        ]
    ]

viewButton :: Button -> Boolean -> Html Action
viewButton button@(Button { name }) isActive =
    if isActive then
        H.li [A.className "active"] [
           H.a [] [
                H.text name
           ]
        ]
    else
        H.li [] [
            H.a [E.onClick (const (Clicked button))] [
                H.text name
            ]
        ]

isActive :: State -> Button -> Boolean
isActive (Selected selected) button | button == selected = true
isActive _ _ = false

searchBarText :: State -> String
searchBarText (SearchTerms searchTerms) = searchTerms
searchBarText _ = ""
