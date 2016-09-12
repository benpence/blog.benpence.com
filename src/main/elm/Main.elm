module Main exposing (main)

import Blog.Api              as Api
import Html.App              as App
import Blog.Model            as Model

main =
    App.program {
        init = Model.init,
        view = Model.view,
        update = Model.update (Api.remoteClient Api.emptyCache),
        subscriptions = \_ -> Sub.none
    }
