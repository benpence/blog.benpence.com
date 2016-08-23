module Blog.Decode exposing (..)

import Json.Decode exposing ( Decoder, (:=) )

import Json.Decode           as Json
import Blog.Model            as Model

user : Decoder Model.User
user = Json.object2 Model.User
    ("id"             := Json.int)
    ("name"           := Json.string)

post : Decoder Model.Post
post = Json.object6 Model.Post
    ("id"             := Json.int)
    ("author"         := user)
    ("title"          := Json.string)
    ("created_millis" := Json.int)
    ("tags"           := (Json.list Json.string))
    ("content"        := Json.string)
