module Blog.Api exposing ( Client, remoteClient )

import Blog.Types exposing ( Page, Post )
import Task exposing ( Task )

import Blog.Decode           as Decode
import                          Http
import Json.Decode           as Json

type Error a
    = InputError String
    | ClientError a

type alias Client a = {
    fetchPosts : String -> Task (Error a) (List Post)
}

remoteClient : Client Http.Error
remoteClient = { fetchPosts = remoteFetchPosts }

-- TODO: Search terms
remoteFetchPosts : String -> Task Error (List Post)
remoteFetchPosts searchTerms =
  let
    url = remotePostsUrl { page = 1, pageSize = 10 }
    decode = decodeResponse (Json.list Decode.post)
  in
     Http.get decode url 

remotePostsUrl : Page -> String
remotePostsUrl page =
    Http.url mostRecentRemotePath [
        ("page", toString page.page),
        ("page_size", toString page.pageSize)
    ]

mostRecentRemotePath = "/api/post/most_recent"

decodeResponse : Json.Decoder a -> Json.Decoder a
decodeResponse = Json.at ["results"]


memoryClient : List Post -> List (Tag, Int) -> Client ()
memoryClient tags posts = {

memoryFetchPosts : String -> Task (Error ()) (List Post)
memoryFetchPosts = 
