module Blog.Posts exposing ( Event(..), view, viewContent, viewTitle )

import Blog.Tag exposing ( Tag )
import Blog.Types exposing ( Post, PostId )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

import                          Date
import Blog.Decode           as Decode
import Html                  as Html
import Blog.Markdown         as Markdown
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
        viewTitle  [
            a [onClick (PostClicked post.id)] [text post.title]
        ],

        div [class "post-date-tags"] [
            -- TODO: Date string
            span [class "post-date"] [text (viewTimestamp post.createdMillis)],

            Html.map fromTagEvent (Tag.viewButtons tags)
        ],

        viewContent post.content
    ]

viewTitle : List (Html a) -> Html a
viewTitle = h1 [class "post-title"]

viewContent : String -> Html a
viewContent content = div [class "post-content"] [Markdown.render content]

viewTimestamp : Int -> String
viewTimestamp epochMillis =
  let
    date = Date.fromTime (toFloat epochMillis)
    year = toString (Date.year date)
    month = case Date.month date of
      Date.Jan -> "01"
      Date.Feb -> "02"
      Date.Mar -> "03"
      Date.Apr -> "04"
      Date.May -> "05"
      Date.Jun -> "06"
      Date.Jul -> "07"
      Date.Aug -> "08"
      Date.Sep -> "09"
      Date.Oct -> "10"
      Date.Nov -> "11"
      Date.Dec -> "12"
    day = toString (Date.day date)
  in
    year ++ "-" ++ month ++ "-" ++ day

fromTagEvent : Tag.Event -> Event
fromTagEvent (Tag.Clicked tag) = TagClicked tag
