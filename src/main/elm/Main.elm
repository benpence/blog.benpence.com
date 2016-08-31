module Main exposing (main)

--import Blog.Api              as Api
import Html.App              as App
--import Blog.Model            as Model
import Blog.View             as View

import Blog.Types exposing ( Post, PostId(..), User, UserId(..) )
import Blog.Tag exposing ( Tag )

--init =
--    View.TagsContent [
--        ({ name = "Alpha" }, 10),
--        ({ name = "Beta" }, 20),
--        ({ name = "Charlie" }, 50)
--    ]
init = View.PostsContent {
    searchTerms = "",
    posts = [
        { id = PostId 1,
          author  = ({ id = UserId 1, name = "ben" }),
          title = "The Ins of a Happy Life",
          createdMillis = 555,
          tags = ["Modeling", "Happy", "Pete's"],
          content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus egestas sit amet purus in sollicitudin. Donec a purus velit. Vivamus ultrices est efficitur nisl consequat ultrices. Vivamus condimentum mattis condimentum. Ut felis justo, aliquam et vestibulum et, accumsan nec odio. Donec euismod dictum justo at porttitor. Maecenas massa elit, sagittis vitae tincidunt ut, volutpat id nisi. Suspendisse potenti. Aliquam non elit vel tellus tristique condimentum in at orci. Vestibulum nisl metus, eleifend non venenatis at, placerat sit amet nibh. Nullam dignissim pharetra orci non fringilla. Suspendisse potenti. Quisque ut vestibulum mauris. Vestibulum imperdiet sit amet nunc in condimentum."
        },
        { id = PostId 2,
          author = ({ id = UserId 1, name = "ben" }),
          title = "Happy People Eat Galaxies",
          createdMillis = 8879,
          tags = ["Tweet", "Poop", "Saraphin"],
          content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus egestas sit amet purus in sollicitudin. Donec a purus velit. Vivamus ultrices est efficitur nisl consequat ultrices. Vivamus condimentum mattis condimentum. Ut felis justo, aliquam et vestibulum et, accumsan nec odio. Donec euismod dictum justo at porttitor. Maecenas massa elit, sagittis vitae tincidunt ut, volutpat id nisi. Suspendisse potenti. Aliquam non elit vel tellus tristique condimentum in at orci. Vestibulum nisl metus, eleifend non venenatis at, placerat sit amet nibh. Nullam dignissim pharetra orci non fringilla. Suspendisse potenti. Quisque ut vestibulum mauris. Vestibulum imperdiet sit amet nunc in condimentum."
        }
    ]
    }

main =
    App.program {
        init = (init, Cmd.none),
        view = \_ -> View.view init,
        update = \e i -> (\_ _ -> (init, Cmd.none)) (Debug.log "Event" e) i,
        subscriptions = \_ -> Sub.none
    }
