module Blog.Decode exposing (..)

import Blog.Types exposing ( Post, PostId(..), User, UserId(..) )
import Blog.Tag exposing ( Tag )
import Json.Decode exposing ( Decoder, (:=) )

import Json.Decode           as Json

userId : Decoder UserId
userId = Json.map UserId Json.int

user : Decoder User
user = Json.object2 User
    ("id"             := userId)
    ("name"           := Json.string)

postId : Decoder PostId
postId = Json.map PostId Json.int

post : Decoder Post
post = Json.object6 Post
    ("id"             := postId)
    ("author"         := user)
    ("title"          := Json.string)
    ("created_millis" := Json.int)
    ("tags"           := (Json.list Json.string))
    ("content"        := Json.string)

tag : Decoder Tag
tag = Json.map (\name -> { name = name }) Json.string

tagCount : Decoder (Tag, Int)
tagCount = Json.object2 (,)
    ("tag"            := tag)
    ("count"          := Json.int)

posts : Decoder (Int, List Post)
posts = Json.object2 (,)
    ("total_pages"    := Json.int)
    ("posts"          := (Json.list post))
