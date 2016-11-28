module Blog.Header exposing ( aboutButton, Button, Event(..), Header(..), postsButton, tagsButton, view )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick, onInput )

searchPlaceholder = "Search for posts"

type alias Button = {
    name : String
}

type Event
    = Clicked Button
    | NewSearchTerms String

type Header
    = Selected Button
    | SearchTerms String

view : Header -> Html Event
view header =
  let
    isActive button = case header of
        (Selected selected) -> selected == button
        _ -> False
  in
    nav [class "row navbar navbar-default"] [
        div [class "navbar-header", style [("margin-right", "15px")]] [
            ul [class "nav navbar-nav"] (List.map (\b -> viewButton b (isActive b)) buttons)
        ],

        div [class "navbar-form"] [
            div [class "form-group", style [("display", "inline")]] [
                div [class "input-group", style [("display", "table"), ("left-margin", "15px")]] [
                    span [class "input-group-addon", style [("width", "1%")]] [
                         span [class "glyphicon glyphicon-search"] []
                    ],

                    input [
                        onInput NewSearchTerms,
                        type_ "text",
                        class "form-control",
                        placeholder searchPlaceholder
                    ] []
                ]
            ]
        ]
    ]

viewButton : Button -> Bool -> Html Event
viewButton button isActive =
    if isActive then
        li [class "active"] [
           a [] [
               text button.name
           ]
        ]
    else
        li [] [
          a [onClick (Clicked button)] [
              text button.name
          ]
        ]

postsButton = { name = "Posts" }
tagsButton  = { name = "Tags" }
aboutButton = { name = "About" }

buttons : List Button
buttons = [postsButton, tagsButton, aboutButton]
