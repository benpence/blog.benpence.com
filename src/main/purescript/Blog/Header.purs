module Blog.Header
  ( Button(..)
  , buttons
  , component
  , State(..)
  , initialState
  , Query(..)
  , render
) where

import Halogen (Component, ComponentDSL, ComponentHTML)
import Halogen.HTML (className)
import Prelude

import Halogen                                   as Halogen
import Halogen.HTML.Events.Indexed               as E
import Halogen.HTML.Indexed                      as H
import Halogen.HTML.Properties.Indexed           as P

newtype Button = Button { name :: String }
derive instance eqButton :: Eq Button
derive instance ordButton :: Ord Button

data Query a
    = Clicked Button a
    | NewSearchTerms String a
    | GetState (State -> a)

data State
    = Selected Button
    | SearchTerms String

initialState :: State
initialState = Selected postsButton

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

component :: forall g. Component State Query g
component = Halogen.component { render, eval }

eval :: forall g. Query ~> ComponentDSL State Query g
eval (Clicked button next) = do
  Halogen.set (Selected button)
  -- TODO: Access API and emit event
  pure next
eval (NewSearchTerms searchTerms next) = do
  Halogen.set (SearchTerms searchTerms)
  -- TODO: Access API and emit event
  pure next
eval (GetState continue) = do
  state <- Halogen.get
  pure (continue state)

render :: State -> ComponentHTML Query
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

renderButton :: Button -> Boolean -> ComponentHTML Query
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

classes :: forall r i. Array String -> P.IProp (class :: P.I | r) i
classes = P.classes <<< map className

isActive :: forall a. State -> Button -> Boolean
isActive (Selected selected) button | button == selected = true
isActive _ _ = false

searchBarText :: State -> String
searchBarText (SearchTerms searchTerms) = searchTerms
searchBarText _ = ""
