module Api
  ( ApiTagCount(..)
  , ApiUser(..)
  , ApiPost(..)
  , ApiPosts(..)
  , Result(..)
  , remoteSearchPosts
  , remoteAbout
  ) where

import Control.Monad.Aff (Aff)
import Data.Argonaut.Core (Json, JObject)
import Data.Argonaut.Decode (class DecodeJson, (.?), decodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Path.Pathy ((</>))
import Data.Tuple (Tuple(..))
import Network.HTTP.Affjax (AJAX)
import Prelude

import Ajax                                      as Ajax
import Data.HTTP.Method                          as Method
import Data.Path.Pathy                           as P

remoteSearchPosts :: forall r. String -> { number :: Int, size :: Int } -> Aff (ajax :: AJAX | r) (Result ApiPosts)
remoteSearchPosts searchTerms page =
  let
    path = P.rootDir </> P.dir "api" </> P.dir "post" </> P.file "search"

    url = Ajax.makeUrl (Right path) [
        (Tuple "query_string" searchTerms),
        (Tuple "page" (show page.number)),
        (Tuple "page_size" (show page.size))
    ]
  in do
    resp <- Ajax.request Method.GET url Nothing
    pure (decodeResult (resp.response))

remotePostsByTag :: forall r. { name :: String } -> { number :: Int, size :: Int } -> Aff (ajax :: AJAX | r) (Result ApiPosts)
remotePostsByTag tag page =
  let
    path = P.rootDir </> P.dir "api" </> P.dir "post" </> P.file "by_tag"

    url = Ajax.makeUrl (Right path) [
        (Tuple "tag" tag.name),
        (Tuple "page" (show page.number)),
        (Tuple "page_size" (show page.size))
    ]
  in do
    resp <- Ajax.request Method.GET url Nothing
    pure (decodeResult (resp.response))

remotePostById :: forall r. Int -> Aff (ajax :: AJAX | r) (Result ApiPost)
remotePostById id =
  let
    path = P.rootDir </> P.dir "api" </> P.dir "post" </> P.file "by_id"

    url = Ajax.makeUrl (Right path) [
        (Tuple "post_id" (show id))
    ]
  in do
    resp <- Ajax.request Method.GET url Nothing
    pure (decodeResult (resp.response))

remotePostTagCounts :: forall r. Int -> Aff (ajax :: AJAX | r) (Result (Array ApiTagCount))
remotePostTagCounts id =
  let
    path = P.rootDir </> P.dir "api" </> P.file "tagcounts"

    url = Ajax.makeUrl (Right path) [
        (Tuple "post_id" (show id))
    ]
  in do
    resp <- Ajax.request Method.GET url Nothing
    pure (decodeResult (resp.response))

remoteAbout :: forall r. Aff (ajax :: AJAX | r) String
remoteAbout =
  let
    path = P.rootDir </> P.dir "static" </> P.file "About.md"

    url = Ajax.makeUrl (Right path) []
  in
    map _.response (Ajax.request Method.GET url Nothing)

type Result a = Either (Array String) a

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

decodeResult :: forall a. DecodeJson a => Json -> Result a
decodeResult json =
  let
    result :: Either String JObject
    result = decodeJson json

    results :: Either String a
    results = do
        obj     <- result
        results' <- obj .? "results"
        pure results'

    errors :: Either String (Array String)
    errors = do
        obj    <- result
        errors' <- obj .? "errors"
        pure errors'

    altResults :: Either String a -> Either String (Array String) -> Either (Array String) a
    altResults (Right results') _                = Right results'
    altResults _                (Right errors')  = Left errors'
    altResults (Left parseErr1) (Left parseErr2) = Left [parseErr1, parseErr2]
  in
    altResults results errors

instance decodeApiTagCount :: DecodeJson ApiTagCount where
    decodeJson json = do
        obj   <- decodeJson json
        tag   <- obj .? "tag"
        count <- obj .? "count"
        pure (ApiTagCount { tag, count })

instance decodeApiUser :: DecodeJson ApiUser where
    decodeJson json = do
        obj  <- decodeJson json
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
