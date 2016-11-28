module Blog.Api exposing ( Client, remoteClient )

import Blog.Pages exposing ( Page )
import Blog.Types exposing ( Post, PostId(..) )
import Blog.Tag exposing ( Tag )
import Task exposing ( Task )

import Blog.Decode           as Decode
import Blog.Deprecated       as Deprecated
import                          Http
import Json.Decode           as Json
import                          Result
import                          Task

type alias Client = {
    searchPosts : String -> Page -> Task String (Int, List Post),
    postsByTag : Tag -> Page -> Task String (Int, List Post),
    postbyId : PostId -> Task String Post,
    tagCounts : Task String (List (Tag, Int)),
    about : Task String String
}

-- TODO: Make decoder injectable
remoteClient : Client
remoteClient = {
    searchPosts = remoteSearchPosts,
    postsByTag = remotePostsByTag,
    postbyId = remotePostById,
    tagCounts = remoteTagCounts,
    about = remoteAbout
  }

-- searchPosts
remoteSearchPosts : String -> Page -> Task String (Int, List Post)
remoteSearchPosts searchTerms page =
    getJson (remoteSearchPostsUrl searchTerms page) Decode.posts

remoteSearchPostsUrl : String -> Page -> String
remoteSearchPostsUrl searchTerms page =
    Deprecated.url remoteSearchPostsPath [
        ("query_string", Http.encodeUri searchTerms),
        ("page", toString page.page),
        ("page_size", toString page.pageSize)
    ]

remoteSearchPostsPath = "/api/post/search"

-- postsByTag
remotePostsByTag : Tag -> Page -> Task String (Int, List Post)
remotePostsByTag tag page =
    getJson (remotePostsByTagUrl tag page) Decode.posts

remotePostsByTagUrl : Tag -> Page -> String
remotePostsByTagUrl tag page =
    Deprecated.url remotePostsByTagPath [
        ("tag", Http.encodeUri tag.name),
        ("page", toString page.page),
        ("page_size", toString page.pageSize)
    ]

remotePostsByTagPath = "/api/post/by_tag"

-- postsById
remotePostById : PostId -> Task String Post
remotePostById id =
    getJson (remotePostByIdUrl id) Decode.post

remotePostByIdUrl : PostId -> String
remotePostByIdUrl (PostId id) =
    Deprecated.url remotePostByIdPath [
        ("post_id", toString id)
    ]

remotePostByIdPath = "/api/post/by_id"

-- tagCounts
remoteTagCounts : Task String (List (Tag, Int))
remoteTagCounts =
    getJson remoteTagCountsPath (Json.list Decode.tagCount)

remoteTagCountsPath = "/api/tagcounts"

-- about
remoteAbout : Task String String
remoteAbout = Task.mapError toString (Http.toTask (Http.getString remoteAboutPath))

remoteAboutPath = "/static/About.md"

getJson : String -> Json.Decoder a -> Task String a
getJson url decoder =
  let
    request = Http.getString url
    decode = decodeResponse decoder
  in
    Http.toTask request
        |> Task.mapError toString
        |> Task.andThen (Deprecated.fromResult << decode)

decodeResponse : Json.Decoder a -> String -> Result String a
decodeResponse decoder input =
  let
    successes = Json.decodeString (Json.at ["results"] decoder) input
    errors input =
        Json.decodeString (Json.at ["errors"] (Json.list Json.string)) input
            |> Result.andThen (Err << toString)
  in
    case successes of
        Ok results -> Ok results
        Err _ -> errors input
