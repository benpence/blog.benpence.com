module Blog.View exposing (..)

import Blog.Message exposing ( Message )
import Blog.Model exposing ( Post, User )
import Blog.State exposing ( State, State( InitialState, MostRecent ) )
import Html exposing ( Html, a, div, p, span, text )
import Html.Attributes exposing (..)
import Html.Events exposing ( onInput )

view : State -> Html Message
view state = case state of
    InitialState        -> div [] []
    MostRecent posts -> viewPosts posts

viewPosts : List Post -> Html Message
viewPosts posts = div [class "most-recent"] (List.map viewPost posts)

viewPost : Post -> Html Message
viewPost post =
    div [class "post"] [
        p [class "post-title"] [text post.title],
        p [class "post-by"] [
            text "by ",
            viewAuthor post.author
        ],
        p [class "post-on"] [
            text "posted on ",
            span [class "post-date"] [text (toString post.createdMillis)]
        ],
        p [class "post-tags"] (List.map viewTag post.tags),
        div [class "post-content"] [text post.content]
    ]


viewAuthor : User -> Html Message
viewAuthor user = a [class "post-author"] [text user.name]

viewTag : String -> Html Message
viewTag tag = a [class "post-tag"] [text tag]
