module Blog.Model exposing ( update )

import Blog.Tag exposing ( Tag )
import Blog.Types exposing ( Post )
import Html exposing ( Html )
import Task exposing ( Task )

import Blog.Api              as Api
import                          Http
import                          Task
import Blog.View             as View

type alias Model = {
    content : View.Content
}

init : Model
init = { content = View.Empty }

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
    | FetchedTags
        { tags : List Tag
        }
    | FetchedAbout
        { content : String
        }
    | FailedFetch
        { reasons : List String
        }

update : Api.Client -> Event -> Model -> (Model, Cmd Event)
update client event model = let unimplemented = (model, Cmd.none) in case event of
    (ViewEvent (View.ShowPosts { searchTerms })) -> model `withAction`
        (\posts -> FetchedPosts {
            searchTerms = searchTerms,
            posts = posts
        })
        client.fetchPosts searchTerms

    -- TODO: Add API method
    (ViewEvent (View.ShowPost { postId })) -> unimplemented

    -- TODO: Add API method
    (ViewEvent (View.ShowTag { tag })) -> unimplemented

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

    (FetchedTags { tags }) -> model `withContent` (View.TagsContent tags)

    (FetchedAbout { content }) -> model `withContent` content

withContent : Model -> View.Content -> Model
withContent model content = { model | content = (content, Cmd.none) }

withAction : Model -> (List Post -> Event) -> Task Http.Error (List Post) -> Cmd Event
withAction model transform task = (model, Task.map transform FailedFetch task)

view : Model -> Html Event
view { content } = View.view content
