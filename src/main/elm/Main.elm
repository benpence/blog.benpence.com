module Main exposing (main)

import Blog.Api              as Api
import Html                  as Html
import Blog.Model            as Model

main =
    Html.program {
        init = Model.init,
        view = Model.view,
        update = Model.update Api.remoteClient,
        subscriptions = \_ -> Sub.none
    }
