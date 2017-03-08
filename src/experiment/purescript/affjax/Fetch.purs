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

main :: Eff ("err" :: EXCEPTION , "ajax" :: AJAX , "console" :: CONSOLE) (Canceler ( "ajax" :: AJAX , "console" :: CONSOLE))
main = launchAff $ do
    posts <- Api.remoteSearchPosts "a" { number: 1, size: 2 }
    about <- Api.remoteAbout 
    let
        abc (Right (Api.ApiPosts { totalPages })) = show totalPages
        abc (Left errors) = show errors
    liftEff $ log $ "GET /api response: " <> (abc posts) <> about
