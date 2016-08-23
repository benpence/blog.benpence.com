module Blog.Model exposing (..)

type alias User = {
    id   : Int,
    name : String
}

type alias Post = {
    id            : Int,
    author        : User,
    title         : String,
    createdMillis : Int,
    tags          : List String,
    content       : String
}
