module Blog.Tag exposing ( Event(..), Tag, viewButtons, viewCounts )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

type alias Tag = { name : String }

type Event = Clicked Tag

viewButtons : List Tag -> Html Event
viewButtons tags =
    span [class "post-tags"] (List.map viewButton tags)

viewButton : Tag -> Html Event
viewButton tag =
    a [class "post-tag btn btn-default btn-xs", onClick (Clicked tag)] [
        text tag.name
    ]

viewCounts : List (Tag, Int) -> Html Event
viewCounts tagCounts =
    div [class "tag-list list-group"] (
        List.map
            viewCount
            (List.sortBy (\(t, _) -> t.name) tagCounts)
    )

viewCount : (Tag, Int) -> Html Event
viewCount (tag, count) =
    button [onClick (Clicked tag), class "tag-count list-group-item"] [
        text (tag.name ++ " (" ++ toString count ++ ")")
    ]
