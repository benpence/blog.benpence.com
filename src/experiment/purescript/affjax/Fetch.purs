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

import Control.Bind ((=<<))
import Data.Argonaut.Core (Json, JObject)
--import Data.Either (Either(..))
import Data.List                                 as List
import Data.Maybe (Maybe(..))
import Data.URI.Types (URI(..), HierarchicalPart(..), URIPath, URIPathAbs)
import Data.URI as URI    
import Data.Path.Pathy (Abs, File, Path(..), Unsandboxed, (</>))
import Data.Path.Pathy as P

--import Data.Tuple (Tuple(..))
import Control.Alt ((<|>))
import Data.Argonaut.Decode (class DecodeJson, (.?), decodeJson)

toUrl :: URIPathAbs -> Array (Tuple String String) -> String
toUrl uriPath params =
  let
    query = Just (URI.Query (map (\(Tuple param val) -> Tuple param (Just val)) (toList params)))
    hierarchicalPart = HierarchicalPart Nothing (Just uriPath)
    uri = URI.URI Nothing hierarchicalPart query Nothing
  in
    -- URI (Maybe URIScheme) HierarchicalPart (Maybe Query) (Maybe Fragment)
    URI.printURI uri

main :: Eff ("err" :: EXCEPTION , "ajax" :: AJAX , "console" :: CONSOLE) (Canceler ( "ajax" :: AJAX , "console" :: CONSOLE))
main =
  let
    uriPath = P.rootDir </> P.dir "api" </> P.dir "post" </> P.file "search"
    url = toUrl (Right uriPath) [
        (Tuple "query_string" "a"),
        (Tuple "page" "1"),
        (Tuple "page_size" "10")
    ]
  in launchAff $ do
    res <- affjax $ defaultRequest { url = url, method = Left GET }
    let
      ePost :: Either String (ApiResult ApiPosts)
      ePost = decodeJson (res.response)

      abc (Results (ApiPosts { totalPages })) = show totalPages
      abc (Errors errors) = show errors
    liftEff $ log $ "GET /api response: " <> (show (map abc ePost))

data ApiResult a = Results a | Errors (Array String)

newtype ApiTagCount = ApiTagCount
    { tag   :: String
    , count :: Int
    }
newtype ApiUser = ApiUser
    { id   :: Int
    , name :: String
    }
newtype ApiPost = ApiPost
    { id :: Int
    , author :: ApiUser
    , title :: String
    , createdMillis :: Number
    , tags :: Array String
    , content :: String
    }
newtype ApiPosts = ApiPosts
    { totalPages :: Int
    , posts :: Array ApiPost
    }

instance decodeApiResult :: DecodeJson a => DecodeJson (ApiResult a) where
    decodeJson json =
      let
        result :: Either String JObject
        result = decodeJson json

        results :: Either String (ApiResult a)
        results = do
            obj     <- result
            results <- obj .? "results"
            pure (Results results)

        errors :: Either String (ApiResult a)
        errors = do
            obj    <- result
            errors <- obj .? "errors"
            pure (Errors errors)
      in
        errors <|> results

instance decodeApiTagCount :: DecodeJson ApiTagCount where
    decodeJson json = do
        obj   <- decodeJson json
        tag   <- obj .? "tag"
        count <- obj .? "count"
        pure (ApiTagCount { tag, count })

instance decodeApiUser :: DecodeJson ApiUser where
    decodeJson json = do
        obj   <- decodeJson json
        id   <- obj .? "id"
        name <- obj .? "name"
        pure (ApiUser { id, name })

instance decodeApiPost :: DecodeJson ApiPost where
    decodeJson json = do
        obj           <- decodeJson json
        id            <- obj .? "id"
        author        <- obj .? "author"
        title         <- obj .? "title"
        createdMillis <- obj .? "created_millis"
        tags          <- obj .? "tags"
        content       <- obj .? "content"
        pure (ApiPost { id, title, author, createdMillis, tags, content })

instance decodeApiPosts :: DecodeJson ApiPosts where
    decodeJson json = do
        obj        <- decodeJson json
        totalPages <- obj .? "total_pages"
        posts      <- obj .? "posts"
        pure (ApiPosts { totalPages, posts })

-- type AffjaxRequest a = {
--   method :: Either Method CustomMethod, 
--   url :: URL, 
--   headers :: Array RequestHeader, 
--   content :: Maybe a, 
--   username :: Maybe String, 
--   password :: Maybe String, 
--   withCredentials :: Boolean }

toList :: forall a. Array a -> List a
toList = List.fromFoldable
