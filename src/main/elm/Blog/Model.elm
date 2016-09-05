module Blog.Model exposing ( init, update, view )

import Blog.Tag exposing ( Tag )
import Blog.Types exposing ( Post )
import Html exposing ( Html )
import Task exposing ( Task )

import Blog.Api              as Api
import Html.App              as Html
import                          Http
import                          Task
import Blog.View             as View

type alias Model = {
    content : View.Content
}

init : (Model, Cmd Event)
init = (
    { content = View.Empty },
    Task.perform identity identity (Task.succeed (ViewEvent (View.ShowPosts { searchTerms = "" })))
    )

type Event
    = ViewEvent View.Event
    | FetchedPosts
        { searchTerms : String
        , posts : List Post
        }
    | FetchedTag
        { tag : Tag
        , posts : List Post
        }
    | FetchedTagCounts
        { tagCounts : List (Tag, Int)
        }
    | FetchedAbout
        { content : String
        }
    -- TODO: What failed?
    | FailedFetch String

-- TODO: Remove
pageOne = { page = 1, pageSize = 10 }

update : Api.Client -> Event -> Model -> (Model, Cmd Event)
update client event model = let unimplemented = (model, Cmd.none) in case event of
    (ViewEvent (View.ShowPosts { searchTerms })) -> withPostsTask
        model
        (client.searchPosts searchTerms pageOne)
        (\posts -> FetchedPosts { searchTerms = searchTerms, posts = posts })

    -- TODO: Add API method
    (ViewEvent (View.ShowPost { postId })) -> unimplemented

    -- TODO: Add API method
    (ViewEvent (View.ShowTag { tag })) -> withPostsTask
        model
        (client.postsByTag tag pageOne)
        (\posts -> FetchedTag { tag = tag, posts = posts })


    -- TODO: Add API method
    (ViewEvent View.ShowTags) -> unimplemented

    -- TODO: Add API method
    (ViewEvent View.ShowAbout) -> unimplemented

    (FetchedPosts { searchTerms, posts }) -> model `withContent` (View.PostsContent {
        searchTerms = searchTerms,
        posts = posts
    })

    (FetchedTag { tag, posts }) -> model `withContent` (View.TagContent {
        tag = tag,
        posts = posts
    })

    (FetchedTagCounts { tagCounts }) -> model `withContent` (View.TagsContent tagCounts)

    (FetchedAbout { content }) -> model `withContent` View.AboutContent { content = content }

    (FailedFetch reason) -> unimplemented

withContent : Model -> View.Content -> (Model, Cmd a)
withContent model content = ({ model | content = content }, Cmd.none)

withTask : Model -> Task String Event -> (Model, Cmd Event)
withTask model task = (model, Task.perform FailedFetch identity task)

withPostsTask : Model -> Task String (List Post) -> (List Post -> Event) -> (Model, Cmd Event)
withPostsTask model task transform = model `withTask` (Task.map transform task)

view : Model -> Html Event
view { content } = Html.map ViewEvent (View.view content)
