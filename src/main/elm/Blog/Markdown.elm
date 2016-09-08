module Blog.Markdown exposing (render)

import Html exposing (Html)
import Markdown exposing ( defaultOptions )

render : String -> Html a
render = Markdown.toHtmlWith
    { defaultOptions |
        githubFlavored = Just { tables = True, breaks = True },
        smartypants = True
    }
    []
