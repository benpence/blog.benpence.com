module Blog.Route exposing (eventFromLocation, eventToPath, update, view)

import UrlParser exposing (Parser, (</>), (<?>))
import Html exposing (Html)
import Blog.Pages exposing (Page)

import Blog.Deprecated       as Deprecated
import Html                  as Html
import                          Navigation
import UrlParser             as Parser
import Blog.View             as View

type Event e
    = UrlChange Navigation.Location
    | OtherEvent e

init : (m, Cmd e) -> (m, Cmd (Event e))
init (model, cmd) = (model, Cmd.map OtherEvent cmd)

view : (m -> Html e) -> m -> Html (Event e)
view viewModel model = Html.map OtherEvent (viewModel model)

update : View.Event -> (View.Event -> e) -> (e -> m -> (m, Cmd e)) -> Event e -> m -> (m, Cmd (Event e))
update defaultView wrapViewEvent updateModel event = init <| case event of
    (UrlChange location) -> case eventFromLocation location of
        Just viewEvent -> updateModel (wrapViewEvent viewEvent)
        Nothing -> updateModel (wrapViewEvent defaultView)
    (OtherEvent evt) -> updateModel evt

eventFromLocation : Int -> Navigation.Location -> Maybe View.Event
eventFromLocation pageSize =
  let
    toPage page = Page { page = page, pageSize = pageSize }
  in
    Parser.parsePath
        (Parser.oneOf
            [ Parser.map (\searchTerms page -> View.ShowPosts { searchTerms = searchTerms, page = toPage page })
                (Parser.s "posts" <?> Parser.requiredStringParam "q" <?> Parser.requiredIntParam "page")
            , Parser.map (\postId -> View.ShowPost { postId = postId })
                (Parser.s "post" </> Parser.int) 
            , Parser.map (\tagName page -> View.ShowTag { tag = { name = tagName }, page = toPage page })
                (Parser.s "tag" </> Parser.string <?> Parser.requiredIntParam "page")
            , Parser.map View.ShowTags
                (Parser.s "tags")
            , Parser.map View.ShowAbout
                (Parser.s "about")
            ]
        )

showPostsParser : Parser (        

eventToPath : Int -> View.Event -> String
eventToPath pageSize event = case event of
    (View.ShowPosts { searchTerms, page }) -> Deprecated.url "/posts" [
        ("q", toString searchTerms),
        ("page", toString page.page)
    ]
    (View.ShowPost { postId }) -> "/post/" ++ toString postId
    (View.ShowTag { tag,  page }) -> Deprecated.url ("/tag/" ++ tag.name) [
        ("page", toString page.page)
    ]
    View.ShowTags -> "/tags"
    View.ShowAbout -> "/about"
