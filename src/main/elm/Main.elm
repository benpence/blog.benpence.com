module Main exposing (main)

import Blog.Api              as Api
import Html                  as Html
import Blog.Model            as Model
import                          Navigation
import Blog.Route            as Route

pageSize : Int
pageSize = 10

main =
    Navigation.program Route.UrlChange {
        init = Route.init Model.init,
        view = Route.view Model.view,
        update = Route.update (View.defaultView pageSize) Model.ViewEvent (Model.update Api.remoteClient),
        subscriptions = \_ -> Sub.none
    }
