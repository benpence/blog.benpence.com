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
    nav [class "row navbar navbar-default"] [
        div [class "navbar-header"] [
            ul [class "nav navbar-nav"] (List.map viewButton buttons)
        ],

        Html.form [class "navbar-form"] [
            div [class "form-group", style [("display", "inline")]] [
                div [class "input-group", style [("display", "table")]] [
                    span [class "input-group-addon", style [("width", "1%")]] [
                         span [class "glyphicon glyphicon-search"] []
                    ],

                    input [
                        onInput NewSearchTerms,
                        type' "text",
                        class "form-control",
                        placeholder searchPlaceholder
                    ] []
                ]
            ]
        ]
    ]

viewButton : Button -> Html Event
viewButton button =
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
