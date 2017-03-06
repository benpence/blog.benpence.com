module Main where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Signal.Channel (CHANNEL)
import Prelude

import Blog.Header                               as Header
import Pux                                       as Pux

main :: Eff ("channel" :: CHANNEL, "err" :: EXCEPTION) Unit
main = do
    app <- Pux.start
        { initialState: Header.init
        , update: Pux.fromSimple Header.update
        , view: Header.view
        , inputs: [] }

    Pux.renderToDOM "body" app.html
