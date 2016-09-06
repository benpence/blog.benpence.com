module Blog.View exposing (Content(..), Event(..), view)

import Blog.Header exposing ( Header )
import Blog.Types exposing ( Post, PostId )
import Blog.Tag exposing ( Tag )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onInput )

import Blog.Header           as Header
import Html.App              as Html
import Blog.Posts            as Posts
import Blog.Tag              as Tag 

type Content
    = Empty
    | PostContent {
        post : Post
    }
    | PostsContent {
        searchTerms : String,
        posts : List Post
    }
    | TagContent {
        tag : Tag,
        posts : List Post
    }
    | TagsContent (List (Tag, Int))
    | AboutContent {
        content : String
    }

type Event
    = ShowPosts {
        searchTerms : String
    }
    | ShowPost {
        postId : PostId
    }
    | ShowTag {
        tag : Tag
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
        if      button == Header.postsButton then ShowPosts { searchTerms = "" }
        else if button == Header.tagsButton  then ShowTags
        else                                      ShowAbout

    (Header.NewSearchTerms searchTerms) -> ShowPosts { searchTerms = searchTerms }
    
viewBody : Content -> Html Event
viewBody content = case content of
    Empty -> div [] []

    (PostsContent { searchTerms, posts }) -> singleRowCol [
        div [class "posts"] [
            Html.map fromPostsEvent (Posts.view posts)
        ]
    ]

    (PostContent { post }) -> viewBody (PostsContent {
        searchTerms = "",
        posts = [post]
    })


    (TagContent { tag, posts }) -> singleRowCol [
        div [class "tag-heading"] [text tag.name],
        Html.map fromPostsEvent (Posts.view posts)
    ]

    (TagsContent tags) ->  singleRowCol [
        div [class "tag-list list-group"] [
          Html.map fromTagEvent (Tag.viewCounts tags)
        ]
    ]

    -- TODO: Render About content
    (AboutContent { content }) -> singleRowCol [text content]

fromPostsEvent : Posts.Event -> Event
fromPostsEvent event = case event of
    (Posts.PostClicked postId) -> ShowPost { postId = postId }
    (Posts.TagClicked tag) -> ShowTag { tag = tag }

fromTagEvent : Tag.Event -> Event
fromTagEvent (Tag.Clicked tag) = ShowTag { tag = tag }

singleRowCol : List (Html a) -> Html a
singleRowCol content = div [class "row"] [div [class "col-lg-12"] content]
