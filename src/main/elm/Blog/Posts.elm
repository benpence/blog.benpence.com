module Blog.Posts exposing ( Event(..), view )

import Blog.Tag exposing ( Tag )
import Blog.Types exposing ( Post, PostId )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import Blog.Decode           as Decode
import Html.App              as Html
import Blog.Tag              as Tag

type Event
    = PostClicked PostId
    | TagClicked Tag

view : List Post -> Html Event
view posts =
    div [class "posts"] (List.map viewPost posts)

viewPost : Post -> Html Event
viewPost post =
  let
    tags = List.map (\name -> { name = name }) post.tags
  in
    div [class "post"] [
        h1 [class "post-title", onClick (PostClicked post.id)] [
            text post.title
        ],

        div [class "post-date-tags"] [
            -- TODO: Date string
            span [class "post-date"] [text (toString post.createdMillis)],

            Html.map fromTagEvent (Tag.viewButtons tags)
        ],

        -- TODO: Render content
        div [class "post-content"] [text post.content]
    ]

fromTagEvent : Tag.Event -> Event
fromTagEvent (Tag.Clicked tag) = TagClicked tag
