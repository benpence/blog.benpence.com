module Blog.Model exposing ( init, update, view )

import Blog.Pages exposing ( Page )
import Blog.Tag exposing ( Tag )
import Blog.Types exposing ( Post )
import Html exposing ( Html )
import Task exposing ( Task )

import Blog.Api              as Api
import Html                  as Html
import                          Http
import Blog.Pages            as Pages
import                          Task
import Blog.View             as View

type alias Model = {
    content : View.Content
}

init : (Model, Cmd Event)
init = (
    { content = View.Empty },
    -- TODO: pageSize
    Task.attempt wrapFailure (Task.succeed (ViewEvent (View.ShowPosts { searchTerms = "", page = Pages.one 10 })))
    )

type Event
    = ViewEvent View.Event
    | FetchedPosts
        { searchTerms : String
        , posts : List Post
        , page : Page
        , totalPages : Int
        }
    | FetchedPost
        { post : Post
        }
    | FetchedTag
        { tag : Tag
        , posts : List Post
        , page : Page
        , totalPages : Int
        }
    | FetchedTagCounts
        { tagCounts : List (Tag, Int)
        }
    | FetchedAbout
        { content : String
        }
    -- TODO: What failed?
    | FailedFetch String

update : Api.Client -> Event -> Model -> (Model, Cmd Event)
update client event model = let unimplemented = (model, Cmd.none) in case event of
    (ViewEvent (View.ShowPosts { searchTerms, page })) -> withPostsTask
        model
        (client.searchPosts searchTerms page)
        (\(totalPages, posts) -> FetchedPosts {
            searchTerms = searchTerms,
            posts = posts,
            page = page,
            totalPages = totalPages
        })

    -- TODO: Add API method
    (ViewEvent (View.ShowPost { postId })) -> withTask model
        (Task.map
            (\post -> FetchedPost { post = post })
            (client.postbyId postId))

    (ViewEvent (View.ShowTag { tag, page })) -> withPostsTask
        model
        (client.postsByTag tag page)
        (\(totalPages, posts) -> FetchedTag {
            tag = tag,
            posts = posts,
            page = page,
            totalPages = totalPages
        })


    -- TODO: Add API method
    (ViewEvent View.ShowTags) -> withTask model
        (Task.map
            (\tagCounts -> FetchedTagCounts { tagCounts = tagCounts })
            client.tagCounts)

    (ViewEvent View.ShowAbout) -> withTask model
        (Task.map
            (\content -> FetchedAbout { content = content })
            client.about)

    (FetchedPosts { searchTerms, posts, page, totalPages }) -> withContent model
        (View.PostsContent {
            searchTerms = searchTerms,
            posts = posts,
            page = page,
            totalPages = totalPages
        })

    (FetchedPost { post }) -> withContent model (View.PostContent {
        post = post
    })

    (FetchedTag { tag, posts, page, totalPages }) -> withContent model (View.TagContent {
        tag = tag,
        posts = posts,
        page = page,
        totalPages = totalPages
    })

    (FetchedTagCounts { tagCounts }) -> withContent model(View.TagsContent tagCounts)

    (FetchedAbout { content }) -> withContent model (View.AboutContent { content = content })

    (FailedFetch reason) -> unimplemented

withContent : Model -> View.Content -> (Model, Cmd a)
withContent model content = ({ model | content = content }, Cmd.none)

withTask : Model -> Task String Event -> (Model, Cmd Event)
withTask model task = (model, Task.attempt wrapFailure task)

withPostsTask : Model -> Task String ((Int, List Post)) -> ((Int, List Post) -> Event) -> (Model, Cmd Event)
withPostsTask model task transform = withTask model (Task.map transform task)

wrapFailure : Result String Event -> Event
wrapFailure result = case result of
    Ok event -> event
    Err msg -> FailedFetch msg

view : Model -> Html Event
view { content } = Html.map ViewEvent (View.view content)
