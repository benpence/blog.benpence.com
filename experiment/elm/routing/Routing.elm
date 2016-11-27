import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import UrlParser exposing (Parser, (</>), (<?>))

import                          Http
import                          Navigation
import UrlParser             as Parser

type alias PostId = Int
type alias Page = Int
type alias SearchTerms = String
type History = Posts SearchTerms Page | Post PostId | Tags | About

historyToHash : History -> String
historyToHash history = case history of
    (Posts searchTerms page) -> Http.url "#/posts" [
        ("q", searchTerms)
        ("page", page)
    ]
    (Post postId) -> "#/post/" ++ (show postId)
    Tags -> "#/tags"
    About -> "#/about"

historyFromHash : Navigation.Location -> Maybe History
historyFromHash hash = Parser.parseHash
    (Parse.oneOf
        [ Parser.map Posts (s "posts" <?> stringParam "q" <?> intParam "page")
        , Parser.map Post  (s "post" </> int) 
        , Parser.map Tags  (s "tags")
        , Parser.map About (s "about")
        ]
    )

main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }

type alias Model = List History

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  ( Model [ location ]
  , Cmd.none
  )

type Event = UrlChange Navigation.Location

update : Event -> Model -> (Model, Cmd Msg)
update event history = case event of
    UrlChange location -> case historyFromHash location of
        Just newHistory -> (newHistory :: history, Cmd.none)
        Nothing ->         (Posts "" 1 :: history, Cmd.none)

view : Model -> Html msg
view history =
    div []
        [ h1 [] [text "History"]
        , ul [] (List.map (text . historyToHash) history)
        ]
