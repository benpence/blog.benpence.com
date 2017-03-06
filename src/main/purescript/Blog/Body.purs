module Blog.Body
  ( Action(..)
  , State
  , init
  , view
  ) where

import Blog (Page, Post, PostId, Tag, TagCount)
import Pux.Html (Html)
import Prelude

import Blog.Pages                                as Pages
import Blog.Posts                                as Posts
import Blog.TagCounts                            as TagCounts
import Pux.Html                                  as H
import Pux.Html.Attributes                       as A

data Action
    = ShowPosts
      { searchTerms :: String
      , page :: Page
      }
    | ShowPost
      { postId :: PostId
      }
    | ShowTag
      { tag :: Tag
      , page :: Page
      }
    | ShowTags
    | ShowAbout

data State 
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

init :: State
init = Empty

view :: State -> Html Action
view Empty = H.div [] []
view (PostsContent { searchTerms, posts, page, totalPages }) =
  let
    pageAction pageNumber = ShowPosts
        { searchTerms: searchTerms
        , page: page { number = pageNumber }
        }

    title =
        if searchTerms == ""
        then "Most Recent"
        else "Search \"" <> searchTerms <> "\""
    pagesState = Pages.init title totalPages page.number
  in
    singleRowCol [
        H.div [A.className "posts"] [
            Pages.view pageAction pagesState,
            map fromPostsAction (Posts.view (Posts.init posts))
        ]
    ]

view (PostContent { post }) = singleRowCol [
        H.div [A.className "posts"] [
            map fromPostsAction (Posts.view (Posts.init [post]))
        ]
    ]

view (TagContent { tag, posts, page, totalPages }) =
  let
    pageAction pageNumber = ShowTag
        { tag: tag
        , page: page { number = pageNumber }
        }

    pagesState = Pages.init ("Tag \"" <> tag.name <> "\"") totalPages page.number
  in
    singleRowCol [
      Pages.view pageAction pagesState,
      map fromPostsAction (Posts.view (Posts.init posts))
    ]

view (TagsContent tagCounts) =
    singleRowCol [
        H.div [A.className "tag-list list-group"] [
          map fromTagAction (TagCounts.view (TagCounts.init tagCounts))
        ]
    ]

view (AboutContent { content }) =
    singleRowCol [
        Posts.viewTitle [H.span [] [H.text "About"]],
        map fromPostsAction (Posts.viewContent content)
    ]

singleRowCol :: forall a. Array (Html a) -> Html a
singleRowCol content =
    H.div [A.className "row"] [
        H.div [A.className "col-lg-12"] content
    ]

fromPostsAction :: Posts.Action -> Action
fromPostsAction (Posts.PostClicked postId) = ShowPost { postId: postId }
-- TODO: pageSize
fromPostsAction (Posts.TagClicked tag) = ShowTag { tag: tag, page: Pages.one 10 }
-- TODO: Open page on link clicked
fromPostsAction (Posts.LinkClicked url) = ShowTags

-- TODO: pageSize
fromTagAction :: TagCounts.Action -> Action
fromTagAction (TagCounts.Clicked tag) = ShowTag { tag: tag, page: Pages.one 10 }
