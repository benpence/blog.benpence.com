module Blog.Body
  ( Action(..)
  , State(..)
  , init
  , view
  ) where

import Blog.Types (Page, Post, PostId, Tag, TagCount)
import Pux.Html (Html)
import Prelude

import Blog.Header                               as Header
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
view state =
    H.div [A.className "app container-fluid"] [
        map fromHeaderAction (Header.view (headerState state)),
        viewContent state
    ]

headerState :: State -> Header.State
headerState Empty = Header.init
headerState (PostContent _) = Header.SearchTerms ""
headerState (PostsContent { searchTerms }) =
    if searchTerms == ""
    then Header.Selected Header.postsButton
    else Header.SearchTerms searchTerms
headerState (TagContent _) = Header.SearchTerms ""
headerState (TagsContent _) = Header.Selected Header.tagsButton
headerState (AboutContent _) = Header.Selected Header.aboutButton

viewContent :: State -> Html Action
viewContent Empty = H.div [] []
viewContent (PostsContent { searchTerms, posts, page, totalPages }) =
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

viewContent (PostContent { post }) = singleRowCol [
        H.div [A.className "posts"] [
            map fromPostsAction (Posts.view (Posts.init [post]))
        ]
    ]

viewContent (TagContent { tag, posts, page, totalPages }) =
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

viewContent (TagsContent tagCounts) =
    singleRowCol [
        H.div [A.className "tag-list list-group"] [
          map fromTagAction (TagCounts.view (TagCounts.init tagCounts))
        ]
    ]

viewContent (AboutContent { content }) =
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

-- TODO: pageSize
fromHeaderAction :: Header.Action -> Action
fromHeaderAction (Header.Clicked b) | b == Header.tagsButton = ShowTags
fromHeaderAction (Header.Clicked b) | b == Header.aboutButton = ShowAbout
fromHeaderAction (Header.Clicked _)                           =
    ShowPosts { searchTerms: "", page: Pages.one 10 }
fromHeaderAction (Header.NewSearchTerms searchTerms) =
    ShowPosts { searchTerms: searchTerms, page: Pages.one 10 }
