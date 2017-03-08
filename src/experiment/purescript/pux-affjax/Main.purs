module Main where

import Prelude
import Control.Monad.Aff (Canceler, launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.List (List)
import Data.Tuple (Tuple(..))
import Network.HTTP.Affjax (AJAX, affjax, defaultRequest)

import Data.Argonaut.Core (Json, JObject)
import Data.List                                 as List
import Data.Maybe (Maybe(..))
import Data.URI.Types (URI(..), HierarchicalPart(..), URIPath, URIPathAbs)
import Data.URI as URI    
import Data.Path.Pathy (Abs, File, Path(..), Unsandboxed, (</>))
import Data.Path.Pathy as P

import Api as Api
import Data.Argonaut.Decode (decodeJson)

import Pux                                       as Pux
import Pux.Html                                  as H
import Pux.Html.Events                           as E
import Pux (EffModel)
import Signal.Channel (CHANNEL)

main :: forall r. Eff ("ajax" :: AJAX, "channel" :: CHANNEL, "err" :: EXCEPTION | r) Unit
main = do
    app <- Pux.start
        { initialState: 0
        , update: update
        , view: (\i -> H.div [E.onClick (const Clicked)] [H.text (show i)])
        , inputs: [] }

    Pux.renderToDOM "body" app.html

-- type Update state action eff = action -> state -> EffModel state action eff
-- type EffModel state action eff =
--   { state :: state
--   , effects :: Array (Aff (CoreEffects eff) action) }

data Action = Increment | Clicked
type State = Int

update :: forall eff. Action -> State -> EffModel State Action ("ajax" :: AJAX | eff)
update Increment state = Pux.noEffects (state + 1)
update Clicked state = Pux.onlyEffects state [ do
        posts <- Api.remoteSearchPosts "a" { number: 1, size: 2 }
        pure Increment
    ]
