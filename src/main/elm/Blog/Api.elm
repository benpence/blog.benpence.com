module Blog.Api exposing ( Cache, Client, emptyCache, remoteClient )

import Blog.Pages exposing ( Page )
import Blog.Types exposing ( Post, PostId(..) )
import Blog.Tag exposing ( Tag )
import Dict exposing ( Dict )
import Task exposing ( Task )

import Blog.Decode           as Decode
import                          Dict
import                          Http
import Json.Decode           as Json
import                          Result
import                          Task

type Client = Client {
    searchPosts : String -> Page -> Task String (Client, (Int, List Post)),
    postsByTag : Tag -> Page -> Task String (Client, (Int, List Post)),
    postbyId : PostId -> Task String (Client, Post),
    tagCounts : Task String (Client, List (Tag, List PostId)),
    about : Task String (Client, String)
}

type alias Cache = {
    posts : Dict Int Post,
    tags : Dict String (Int, List PostId)
}

emptyCache : Cache
emptyCache = { posts = Dict.empty, tags = Dict.empty }

--getPost : Cache -> PostId -> Maybe Post
--getPost cache (PostId id) = Dict.get id cache.posts
--
--getTaggedPosts : Cache -> Tag -> Maybe (List PostId)
--getTaggedPosts cache tag = Maybe.map snd (Dict.get tag.name cache.tags)
--
--getTagCounts : Cache -> List (Tag, Int)
--getTagCounts cache = List.map
--    (\(name, (total, _)) ->
--        ({ name = name}, total)
--    )
--    (Dict.toList cache.tags)

withPost : Post -> Cache -> Cache
withPost post cache =
    { cache |
        posts = Dict.insert ((\(PostId id) -> id) post.id) post cache.posts
    }

withPosts : List Post -> Cache -> Cache
withPosts posts cache =
    List.foldl withPost cache posts

withTaggedPosts : (Tag, List PostId) -> Cache -> Cache
withTaggedPosts (tag, postIds) cache =
    { cache |
        tags = Dict.insert tag.name (List.length postIds, postIds) cache.tags
    }

withTaggedPostss : List (Tag, List PostId) -> Cache -> Cache
withTaggedPostss taggedPostss cache =
    List.foldl withTaggedPosts cache taggedPostss

remoteClient : Cache -> Client
remoteClient cache =
  let
    updateCache : (b -> Cache -> Cache) -> (a -> b) -> a -> (Client, a)
    updateCache combine transform a = (remoteClient (combine (transform a) cache), a)

    (<<<) : (c -> d) -> (a -> b -> c) -> (a -> b -> d)
    (<<<) f1 f2 = \a b -> f1 (f2 a b)
  in
    Client {
        searchPosts = Task.map (updateCache withPosts        snd)      <<< remoteSearchPosts,
        postsByTag  = Task.map (updateCache withPosts        snd)      <<< remotePostsByTag,
        postbyId    = Task.map (updateCache withPost         identity) <<  remotePostById,
        tagCounts   = Task.map (updateCache withTaggedPostss identity)     remoteTagCounts,
        about       = Task.map ((,) (remoteClient cache))                  remoteAbout
    }

remoteSearchPosts : String -> Page -> Task String (Int, List Post)
remoteSearchPosts searchTerms page =
  let
    url = remoteSearchPostsUrl searchTerms page
    decode = decodeResponse Decode.posts
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

remotePostsByTag : Tag -> Page -> Task String (Int, List Post)
remotePostsByTag tag page =
  let
    url = remotePostsByTagUrl tag page
    decode = decodeResponse Decode.posts
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

remoteTagCounts : Task String (List (Tag, List PostId))
remoteTagCounts =
  let
    decode = decodeResponse (Json.list Decode.tagCount)
  in
    toString
        `Task.mapError` Http.getString remoteTagCountsPath
        `Task.andThen` (Task.fromResult << decode)

remoteTagCountsPath = "/api/tagcounts"

remoteAbout : Task String String
remoteAbout =
     toString
         `Task.mapError` Http.getString remoteAboutPath

remoteAboutPath = "/static/About.md"

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
