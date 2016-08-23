module Blog.State exposing (..)

import Blog.Model exposing ( Post, User )
import Blog.Message exposing ( Message, Message( FetchSucceed, FetchFail ) )

import Blog.Api              as Api

type State
    = InitialState
    | MostRecent (List Post)

update : Message -> State -> (State, Cmd Message)
update message state = case message of
  FetchSucceed posts -> (MostRecent posts, Cmd.none)
  FetchFail err      -> (state, Cmd.none)
