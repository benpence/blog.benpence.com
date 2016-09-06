module Blog.Api exposing ( Client, remoteClient )

import Blog.Types exposing ( Page, Post, PostId(..) )
import Blog.Tag exposing ( Tag )
import Task exposing ( Task )

import Blog.Decode           as Decode
import                          Http
import Json.Decode           as Json
import                          Result
import                          Task

type alias Client = {
    searchPosts : String -> Page -> Task String (List Post),
    postsByTag : Tag -> Page -> Task String (List Post),
    postbyId : PostId -> Task String Post,
    tagCounts : Task String (List (Tag, Int))
}

-- TODO: Make decoder injectable
remoteClient : Client
remoteClient = {
    searchPosts = remoteSearchPosts,
    postsByTag = remotePostsByTag,
    postbyId = remotePostById,
    tagCounts = remoteTagCounts
  }

remoteSearchPosts : String -> Page -> Task String (List Post)
remoteSearchPosts searchTerms page =
  let
    url = remoteSearchPostsUrl searchTerms page
    decode = decodeResponse (Json.list Decode.post)
  in
     toString
         `Task.mapError` Http.getString url
         `Task.andThen` (Task.fromResult << decode)

remoteSearchPostsUrl : String -> Page -> String
remoteSearchPostsUrl searchTerms page =
    Http.url remoteSearchPostsPath [
        ("query_string", Http.uriEncode searchTerms),
        ("page", toString page.page),
        ("page_size", toString page.pageSize)
    ]

remoteSearchPostsPath = "/api/post/search"

remotePostsByTag : Tag -> Page -> Task String (List Post)
remotePostsByTag tag page =
  let
    url = remotePostsByTagUrl tag page
    decode = decodeResponse (Json.list Decode.post)
  in
     toString
         `Task.mapError` Http.getString url
         `Task.andThen` (Task.fromResult << decode)

remotePostsByTagUrl : Tag -> Page -> String
remotePostsByTagUrl tag page =
    Http.url remotePostsByTagPath [
        ("tag", Http.uriEncode tag.name),
        ("page", toString page.page),
        ("page_size", toString page.pageSize)
    ]

remotePostsByTagPath = "/api/post/by_tag"

remotePostById : PostId -> Task String Post
remotePostById id =
  let
    url = remotePostByIdUrl id
    decode = decodeResponse Decode.post
  in
     toString
         `Task.mapError` Http.getString url
         `Task.andThen` (Task.fromResult << decode)

remotePostByIdUrl : PostId -> String
remotePostByIdUrl (PostId id) =
    Http.url remotePostByIdPath [
        ("post_id", toString id)
    ]

remotePostByIdPath = "/api/post/by_id"

remoteTagCounts : Task String (List (Tag, Int))
remoteTagCounts =
  let
    decode = decodeResponse (Json.list Decode.tagCount)
  in
     toString
         `Task.mapError` Http.getString remoteTagCountsPath
         `Task.andThen` (Task.fromResult << decode)

remoteTagCountsPath = "/api/tagcounts"

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
