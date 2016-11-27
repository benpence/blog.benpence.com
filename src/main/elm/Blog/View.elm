module Blog.View exposing (Content(..), Event(..), view)

import Blog.Header exposing ( Header )
import Blog.Pages exposing ( Page )
import Blog.Types exposing ( Post, PostId )
import Blog.Tag exposing ( Tag )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onInput )

import Blog.Header           as Header
import Html.App              as Html
import Blog.Pages            as Pages
import Blog.Posts            as Posts
import Blog.Markdown         as Markdown
import Blog.Tag              as Tag 

type Content
    = Empty
    | PostContent {
        post : Post
    }
    | PostsContent {
        searchTerms : String,
        posts : List Post,
        page : Page,
        totalPages : Int
    }
    | TagContent {
        tag : Tag,
        posts : List Post,
        page : Page,
        totalPages : Int
    }
    | TagsContent (List (Tag, Int))
    | AboutContent {
        content : String
    }

type Event
    = ShowPosts {
        searchTerms : String,
        page : Page
    }
    | ShowPost {
        postId : PostId
    }
    | ShowTag {
        tag : Tag,
        page : Page
    }
    | ShowTags
    | ShowAbout

view : Content -> Html Event
view content =
    div [class "app container-fluid"] [
        Html.map fromHeaderEvent (Header.view (toHeader content)),
        viewBody content 
    ]

toHeader : Content -> Header
toHeader content = case content of 
    Empty -> Header.SearchTerms ""

    (PostsContent { searchTerms }) ->
        if searchTerms == "" then Header.Selected Header.postsButton
        else Header.SearchTerms searchTerms

    (PostContent _) -> Header.SearchTerms ""

    (TagContent _) -> Header.SearchTerms ""

    (TagsContent _) -> Header.Selected Header.tagsButton

    (AboutContent _) -> Header.Selected Header.aboutButton

fromHeaderEvent : Header.Event -> Event
fromHeaderEvent event = case event of
    (Header.Clicked button) ->
        if button == Header.postsButton then ShowPosts {
            searchTerms = "",
            -- TODO: Move pageSize out of this API
            page = Pages.one 10
        }
        else if button == Header.tagsButton  then ShowTags
        else                                      ShowAbout

    (Header.NewSearchTerms searchTerms) -> ShowPosts {
        searchTerms = searchTerms,
        -- TODO: Move pageSize out of this API
        page = Pages.one 10
    }
    
viewBody : Content -> Html Event
viewBody content = case content of
    Empty -> div [] []

    (PostsContent { searchTerms, posts, page, totalPages }) -> singleRowCol [
        div [class "posts"] [
            Pages.view
                (\pageNumber -> ShowPosts {
                    searchTerms = searchTerms,
                    page = { page | page = pageNumber }
                })
                {
                    totalPages = totalPages,
                    currentPage = page.page,
                    title =
                        if searchTerms == "" then "Most Recent"
                        else "Search \"" ++ searchTerms ++ "\""
                },
            Html.map fromPostsEvent (Posts.view posts)
        ]
    ]

    (PostContent { post }) -> singleRowCol [
        div [class "posts"] [
            Html.map fromPostsEvent (Posts.view [post])
        ]
    ]

    (TagContent { tag, posts, page, totalPages }) -> singleRowCol [
        Pages.view
            (\pageNumber -> ShowTag {
                tag = tag,
                page = { page | page = pageNumber }
            })
            {
                totalPages = totalPages,
                currentPage = page.page,
                title = "Tag \"" ++ tag.name ++ "\""
            },
        Html.map fromPostsEvent (Posts.view posts)
    ]

    (TagsContent tags) ->  singleRowCol [
        div [class "tag-list list-group"] [
          Html.map fromTagEvent (Tag.viewCounts tags)
        ]
    ]

    (AboutContent { content }) -> singleRowCol [
      Posts.viewTitle [text "About"],
      Posts.viewContent content
    ]

fromPostsEvent : Posts.Event -> Event
fromPostsEvent event = case event of
    (Posts.PostClicked postId) -> ShowPost { postId = postId }
    -- TODO: pageSize
    (Posts.TagClicked tag) -> ShowTag { tag = tag, page = Pages.one 10 }

-- TODO: pageSize
fromTagEvent : Tag.Event -> Event
fromTagEvent (Tag.Clicked tag) = ShowTag { tag = tag, page = Pages.one 10 }

singleRowCol : List (Html a) -> Html a
singleRowCol content = div [class "row"] [div [class "col-lg-12"] content]
