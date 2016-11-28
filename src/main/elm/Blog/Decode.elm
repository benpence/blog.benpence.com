module Blog.Decode exposing (..)

import Blog.Types exposing ( Post, PostId(..), User, UserId(..) )
import Blog.Tag exposing ( Tag )
import Json.Decode exposing ( Decoder )

import Json.Decode           as Json

userId : Decoder UserId
userId = Json.map UserId Json.int

user : Decoder User
user = Json.map2 User
    (Json.field "id"             userId)
    (Json.field "name"           Json.string)

postId : Decoder PostId
postId = Json.map PostId Json.int

post : Decoder Post
post = Json.map6 Post
    (Json.field "id"             postId)
    (Json.field "author"         user)
    (Json.field "title"          Json.string)
    (Json.field "created_millis" Json.int)
    (Json.field "tags"           (Json.list Json.string))
    (Json.field "content"        Json.string)

tag : Decoder Tag
tag = Json.map (\name -> { name = name }) Json.string

tagCount : Decoder (Tag, Int)
tagCount = Json.map2 (,)
    (Json.field "tag"            tag)
    (Json.field "count"          Json.int)

posts : Decoder (Int, List Post)
posts = Json.map2 (,)
    (Json.field "total_pages"    Json.int)
    (Json.field "posts"          (Json.list post))
