module Main exposing (main)

import Blog.State exposing ( State( InitialState ), update )
import Blog.View exposing ( view )

import Blog.Api              as Api
import Html.App              as App

main =
  let
    client = Api.remoteClient "/api"
  in
    App.program {
        init = (InitialState, client.fetchMostRecentPosts 10),
        view = view,
        update = update,
        subscriptions = \_ -> Sub.none
    }
