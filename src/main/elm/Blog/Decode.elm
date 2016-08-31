module Blog.Decode exposing (..)

import Blog.Types exposing ( Post, PostId(..), User, UserId(..) )
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
