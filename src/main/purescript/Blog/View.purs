module Blog.View
  ( Action(..)
  , State
  , init
  , update
  , view
  ) where

import Blog.Types (Post)
import Control.Monad.Aff (Aff)
import Data.Either (Either(..))
import Network.HTTP.Affjax (AJAX)
import Pux.Html (Html)
import Prelude

import Blog.Api                                  as Api
import Blog.Body                                 as Body
import Pux                                       as Pux

data Action
    = NewBody Body.State
    | ApiRequest Body.Action

type State = Body.State

init :: State
init = Body.Empty

view :: State -> Html Action
view = map ApiRequest <<< Body.view

update :: forall eff. Api.Client -> Action -> State -> Pux.EffModel State Action ("ajax" :: AJAX | eff)
update client (NewBody body) state = Pux.noEffects body
update client (ApiRequest action) state = Pux.onlyEffects state [ do
    result <- contactApi client action
    case result of
        (Right newState) -> pure (NewBody newState)
        -- TODO: Log errors
        (Left errors) -> pure (NewBody state)
]

contactApi :: forall r. Api.Client -> Body.Action -> Aff ("ajax" :: AJAX | r) (Api.Result Body.State)
contactApi client Body.ShowTags = do
    result <- client.tagCounts
    pure (map Body.TagsContent result)
contactApi client Body.ShowAbout =
  let
    toBody :: String -> Body.State
    toBody content = Body.AboutContent { content: content }
  in do
    result <- client.about
    pure (map toBody result)
contactApi client (Body.ShowPosts { searchTerms, page }) =
  let
    toBody :: Api.Posts -> Body.State
    toBody { totalPages, posts } =
        Body.PostsContent { searchTerms, posts, page, totalPages }
  in do
    result  <- client.searchPosts searchTerms page
    pure (map toBody result)
contactApi client (Body.ShowTag { tag, page }) =
  let
    toBody :: Api.Posts -> Body.State
    toBody { totalPages, posts } =
        Body.PostsContent { searchTerms: "", posts, page, totalPages }
  in do
    result  <- client.postsByTag tag page
    pure (map toBody result)
contactApi client (Body.ShowPost { postId }) =
  let
    toBody :: Post -> Body.State
    toBody post = Body.PostContent { post: post }
  in do
    result <- client.postById postId
    pure (map toBody result)
