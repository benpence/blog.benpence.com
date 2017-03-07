module Blog.Posts
  ( Action(..)
  , State
  , init
  , view
  , viewTitle
  , viewContent
  ) where

import Blog (Post, PostId, Tag)
import Data.Enum (class BoundedEnum)
import Data.Either (Either(..))
import Data.Maybe (Maybe, fromMaybe)
import Data.Time.Duration (Milliseconds(..))
import Pux.Html (Html)
import Prelude

import Data.DateTime                             as DateTime
import Data.DateTime.Instant                     as Instant
import Data.Enum                                 as Enum
import Data.Int                                  as Int
import Data.String                               as String
import Blog.TagList                              as TagList
import Blog.Util.Markdown                        as Markdown
import Pux.Html                                  as H
import Pux.Html.Attributes                       as A
import Pux.Html.Events                           as E

data Action
    = PostClicked PostId
    | TagClicked Tag
    | LinkClicked String

type State =
    { posts :: Array Post
    }

init :: Array Post -> State
init = { posts: _ }

view :: State -> Html Action
view state =
    H.div [A.className "posts"] (map viewPost state.posts)

viewPost :: Post -> Html Action
viewPost post =
  let
    tags = map ({ name: _ }) post.tags
  in
    H.div [A.className "post"] [
        viewTitle [
            H.a [E.onClick (const (PostClicked post.id))] [H.text post.title]
        ],

        H.div [A.className "post-date-tags"] [
            H.span [A.className "post-date"] [
                -- TODO: Handle invalid date
                H.text (fromMaybe "" (viewTimestamp post.createdMillis))
            ],

            map fromTagListAction (TagList.view { tags: tags })
        ],

        viewContent post.content
    ]

viewTitle :: forall a. Array (Html a) -> Html a
viewTitle = H.h1 [A.className "post-title"]

viewContent :: String -> Html Action
viewContent content =
  let
    handleRenderedMd :: Either String (Html Markdown.Action) -> Html Action
    -- TODO: Better response
    handleRenderedMd (Left _) = H.div [] []
    handleRenderedMd (Right html) = map fromMarkdownAction html
  in
    H.div [A.className "post-content"] [handleRenderedMd (Markdown.toPux content)]
    

viewTimestamp :: Int -> Maybe String
viewTimestamp epochMillis =
  let
    leadingZeroes :: String -> String
    leadingZeroes s = if (String.length s) < 2 then "0" <> s else s

    showDateField :: forall a. BoundedEnum a => a -> String
    showDateField = leadingZeroes <<< show <<< Enum.fromEnum

    dateToString :: DateTime.Date -> String
    dateToString date =
        showDateField (DateTime.year date) <>
        "-" <>
        showDateField (DateTime.month date) <>
        "-" <>
        showDateField (DateTime.day date)

    millisToDate = map (DateTime.date <<< Instant.toDateTime)
        <<< Instant.instant
        <<< Milliseconds
        <<< Int.toNumber
  in
    map dateToString (millisToDate epochMillis)

fromTagListAction :: TagList.Action -> Action
fromTagListAction (TagList.Clicked tag) = TagClicked tag

fromMarkdownAction :: Markdown.Action -> Action
fromMarkdownAction (Markdown.Clicked url) = LinkClicked url