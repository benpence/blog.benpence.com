module Blog.Api exposing ( Client, remoteClient )

import Blog.Types exposing ( Page, Post )
import Blog.Tag exposing ( Tag )
import Task exposing ( Task )

import Blog.Decode           as Decode
import                          Http
import Json.Decode           as Json
import                          Result
import                          Task

type alias Client = {
    fetchPosts : String -> Page -> Task String (List Post),
    fetchByTag : Tag -> Page -> Task String (List Post)
}

-- TODO: Make decoder injectable
remoteClient : Client
remoteClient = {
    fetchPosts = remoteFetchPosts,
    fetchByTag = remoteByTag
  }

remoteFetchPosts : String -> Page -> Task String (List Post)
remoteFetchPosts searchTerms page =
    if searchTerms == "" then remoteMostRecent page
    else remoteContaining searchTerms page

remoteMostRecent : Page -> Task String (List Post)
remoteMostRecent page =
  let
    url = remoteMostRecentUrl page
    decode : String -> Result String (List Post)
    decode = decodeResponse (Json.list Decode.post)
  in
     toString
         `Task.mapError` Http.getString url
         `Task.andThen` (Task.fromResult << decode)

remoteMostRecentUrl : Page -> String
remoteMostRecentUrl page =
    Http.url remoteMostRecentPath [
        ("page", toString page.page),
        ("page_size", toString page.pageSize)
    ]

remoteMostRecentPath = "/api/post/most_recent"

remoteContaining : String -> Page -> Task String (List Post)
remoteContaining searchTerms page =
  let
    url = remoteContainingUrl searchTerms page
    decode = decodeResponse (Json.list Decode.post)
  in
     toString
         `Task.mapError` Http.getString url
         `Task.andThen` (Task.fromResult << decode)

remoteContainingUrl : String -> Page -> String
remoteContainingUrl searchTerms page =
  let
    suffix = Http.uriEncode searchTerms
  in
    -- TODO: Move query over to param
    -- TODO: Page
    Http.url (remoteContainingPath ++ "/" ++ suffix) [
    ]

remoteContainingPath = "/api/post/containing"

remoteByTag : Tag -> Page -> Task String (List Post)
remoteByTag tag page =
  let
    url = remoteByTagUrl tag page
    decode = decodeResponse (Json.list Decode.post)
  in
     toString
         `Task.mapError` Http.getString url
         `Task.andThen` (Task.fromResult << decode)

remoteByTagUrl : Tag -> Page -> String
remoteByTagUrl tag page =
  let
    suffix = Http.uriEncode tag.name
  in
    -- TODO: Move tag over to param
    -- TODO: Page
    Http.url (remoteByTagPath ++ "/" ++ suffix) [
    ]

remoteByTagPath = "/api/post/by_tag"

decodeResponse : Json.Decoder a -> String -> Result String a
decodeResponse decoder input =
  let
    successes = Json.decodeString (Json.at ["results"] decoder) input
    errors input =
        Json.decodeString (Json.at ["errors"] (Json.list Json.string)) input
            `Result.andThen` (Err << toString)
  in
    case successes of
        Ok results -> Ok results
        Err _ -> errors input
