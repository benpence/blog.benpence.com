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

historyToPath : History -> String
historyToPath history = case history of
    (Posts searchTerms page) -> makeUrl "/posts" [
        ("q", toString searchTerms),
        ("page", toString page)
    ]
    (Post postId) -> "/post/" ++ (toString postId)
    Tags -> "/tags"
    About -> "/about"

historyFromLocation : Navigation.Location -> Maybe History
historyFromLocation location = Parser.parsePath
    (Parser.oneOf
        [ Parser.map (Posts "") (Parser.s "posts" <?> Parser.requiredIntParam "page")
        , Parser.map Post  (Parser.s "post" </> Parser.int) 
        , Parser.map Tags  (Parser.s "tags")
        , Parser.map About (Parser.s "about")
        ]
    ) (Debug.log (toString location) location)

main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }

type alias Model = List History

defaultHistory : History
defaultHistory = Posts "" 1


init : Navigation.Location -> ( Model, Cmd Event )
init = handleNewLocation []
    
handleNewLocation : List History -> Navigation.Location -> ( Model, Cmd Event)
handleNewLocation history location =
    case historyFromLocation location of
        Just newHistory -> (newHistory :: history, Cmd.none)
        -- TODO: Log parse failures
        Nothing ->         (history, Navigation.modifyUrl (historyToPath defaultHistory))

type Event = UrlChange Navigation.Location

update : Event -> Model -> (Model, Cmd Event)
update event history = case event of
    UrlChange location -> handleNewLocation history location

view : Model -> Html a
view history =
    div []
        [ h1 [] [text "History"]
        , ul [] (List.map viewHistory history)
        ]

viewHistory : History -> Html a
viewHistory history =
    li [] [
        ul [] [
             li [] [text ("toString :" ++ toString history)],
             li [] [text ("toHash :" ++ historyToPath history)]
         ]
    ]

makeUrl : String -> List ( String, String ) -> String
makeUrl baseUrl query =
    case query of
        [] ->
            baseUrl

        _ ->
            let
                queryPairs =
                    query |> List.map (\( key, value ) -> Http.encodeUri key ++ "=" ++ Http.encodeUri value)

                queryString =
                    queryPairs |> String.join "&"
            in
                baseUrl ++ "?" ++ queryString
