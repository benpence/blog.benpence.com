module Blog.Message exposing (..)

import Blog.Model exposing ( Post )

import                          Http

type Message
    = FetchSucceed (List Post)
    | FetchFail Http.Error
