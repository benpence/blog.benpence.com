module Blog.Api exposing ( Client, remoteClient )

import Blog.Message exposing ( Message, Message( FetchFail, FetchSucceed ) )

import Blog.Decode           as Decode
import                          Http
import Json.Decode           as Json
import                          Task

type alias Client = {
    fetchMostRecentPosts : Int -> Cmd Message
}

remoteClient : String -> Client
remoteClient apiUriBase =
  let
    url = apiUriBase ++ "/" ++ mostRecentPath
    decodeResponse = Json.at ["results"] (Json.list Decode.post)
    task qty = Task.perform FetchFail FetchSucceed (Http.get decodeResponse (url ++ "?page_size=" ++ (toString qty) ++ "&page=0"))
  in
    { fetchMostRecentPosts = task }

mostRecentPath = "post/most_recent"
