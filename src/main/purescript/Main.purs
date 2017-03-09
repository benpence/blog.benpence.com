module Main where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Network.HTTP.Affjax (AJAX)
import Signal.Channel (CHANNEL)
import Prelude

import Blog.Api                                  as Api
import Blog.View                                 as View
import Pux                                       as Pux

main :: forall r. Eff ("ajax" :: AJAX, "channel" :: CHANNEL, "err" :: EXCEPTION | r) Unit
main = do
    app <- Pux.start
        { initialState: View.init
        , update: View.update Api.remoteClient
        , view: View.view
        , inputs: [] }

    Pux.renderToDOM "body" app.html
