module Blog.Types exposing (..)

type UserId = UserId Int

type alias User = {
    id   : UserId,
    name : String
}

type PostId = PostId Int

type alias Post = {
    id            : PostId,
    author        : User,
    title         : String,
    createdMillis : Int,
    tags          : List String,
    content       : String
}

type alias Page = {
    page : Int,
    pageSize : Int
}
