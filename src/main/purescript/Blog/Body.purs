module Blog.Body
  ( component
  , Query(..)
  , State
  ) where

import Blog (Page, Post, PostId, Tag, TagCount)
import Data.Maybe (Maybe(..))
import Halogen (Component, ParentDSL, ParentHTML)
import Prelude

import Blog.TagList                              as TagList
import Halogen                                   as Halogen
import Halogen.HTML.Events.Indexed               as E
import Halogen.HTML.Indexed                      as H
import Halogen.HTML.Properties.Indexed           as P

data Query a
    = ShowPosts
      { searchTerms :: String
      , page :: Page
      } a
    | ShowPost
      { postId :: PostId
      } a
    | ShowTag
      { tag :: Tag
      , page :: Page
      } a
    | ShowTags a
    | ShowAbout a

data Content
    = Empty
    | PostContent {
        post :: Post
    }
    | PostsContent
      { searchTerms :: String
      , posts       :: Array Post
      , page        :: Page
      , totalPages  :: Int
      }
    | TagContent
      { tag        :: Tag
      , posts      :: Array Post
      , page       :: Page
      , totalPages :: Int
      }
    | TagsContent (Array TagCount)
    | AboutContent
      { content :: String
      }

type State =
  { content  :: Content
  }

initialState :: State
initialState = { content: Empty }

component :: forall g. Component State Query g
component = Halogen.parentComponent { render, eval, peek }

data ChildSlot = ContentSlot
derive instance eqChildSlot :: Eq ChildSlot
derive instance ordChildSlot :: Ord ChildSlot


--  H.div_
--    [ H.slot (TickSlot "A") \_ -> { component: ticker, initialState: TickState 100 }
--    , H.slot (TickSlot "B") \_ -> { component: ticker, initialState: TickState 0 }
--         -- ... snip ...
--    ]

render :: State -> ParentHTML TagList.State Query TagList.Query g ChildSlot
render { content: Empty } = H.div_ []
--render { content: PostsContent { searchTerms, posts, page, totalPages } } =
--    singleRowCol [
--        H.div [class "posts"] [
--            Pages.view
--                (\pageNumber -> ShowPosts {
--                    searchTerms = searchTerms,
--                    page = { page | page = pageNumber }
--                })
--                {
--                    totalPages = totalPages,
--                    currentPage = page.page,
--                    title =
--                        if searchTerms == "" then "Most Recent"
--                        else "Search \"" ++ searchTerms ++ "\""
--                },
--            Html.map fromPostsEvent (Posts.view posts)
--        ]
--    ]
--
--    (PostContent { post }) -> singleRowCol [
--        div [class "posts"] [
--            Html.map fromPostsEvent (Posts.view [post])
--        ]
--    ]
--
--    (TagContent { tag, posts, page, totalPages }) -> singleRowCol [
--        Pages.view
--            (\pageNumber -> ShowTag {
--                tag = tag,
--                page = { page | page = pageNumber }
--            })
--            {
--                totalPages = totalPages,
--                currentPage = page.page,
--                title = "Tag \"" ++ tag.name ++ "\""
--            },
--        Html.map fromPostsEvent (Posts.view posts)
--    ]
--
--    (TagsContent tags) ->  singleRowCol [
--        div [class "tag-list list-group"] [
--          Html.map fromTagEvent (Tag.viewCounts tags)
--        ]
--    ]
--
--    (AboutContent { content }) -> singleRowCol [
--      Posts.viewTitle [span [] [text "About"]],
--      Posts.viewContent content
--    ]

-- eval :: Query ~> ParentDSL State TickState Query TickQuery g TickSlot
-- eval (ReadTicks next) = do
--   a <- query (TickSlot "A") (request GetTick)
--   b <- query (TickSlot "B") (request GetTick)
--   modify (\_ -> { tickA: a, tickB: b })
--   pure next

eval :: Query ~> ParentDSL State TagList.State Query TagList.Query g ChildSlot
eval (ShowPosts { searchTerms, page } next) = do
    pure next
eval (ShowPost { postId } next) = do
    pure next
eval (ShowTag { tag, page } next) = do
    pure next
eval (ShowTags next) = do
    pure next
eval (ShowAbout next) = do
    pure next

peek :: forall x. Halogen.ChildF ChildSlot TagList.Query x -> ParentDSL State Task ListQuery TaskQuery g ChildSlot Unit
peek _ = pure unit
