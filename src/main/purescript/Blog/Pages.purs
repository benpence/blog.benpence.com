module Blog.Pages
  ( State
  , init
  , one
  , view
  ) where

import Blog.Types (Page)
import Data.Array ((:))
import Pux.Html (Html)
import Prelude

import Data.Array                                as Array
import Pux.Html                                  as H
import Pux.Html.Attributes                       as A
import Pux.Html.Events                           as E

type State =
  { title       :: String
  , totalPages  :: Int
  , currentPage :: Int
  }

init :: String -> Int -> Int -> State
init title totalPages currentPage = { title, totalPages, currentPage }

view :: forall a. (Int -> a) -> State -> Html a
view pageAction state =
  let
    pages = Array.range 1 state.totalPages
  in
    H.nav [] [
        viewPages pageAction state.title state.currentPage pages
    ]

viewPages :: forall a. (Int -> a) -> String -> Int -> Array Int -> Html a
viewPages pageAction title currentPage pageNumbers =
  let
    pages = map (viewPage pageAction currentPage) pageNumbers
    titleItem = H.li [] [H.span [A.className "page-title"] [H.text title]]
  in
    H.ul [A.className "pagination"] (titleItem : pages)

viewPage :: forall a. (Int -> a) -> Int -> Int -> Html a
viewPage pageAction currentPage pageNumber =
  let
    pageText = [H.text (show pageNumber)]
  in
    if currentPage == pageNumber then
        H.li [A.className "active"] [
            H.a [] pageText
        ]
    else
        H.li [] [
            H.a [E.onClick (const (pageAction pageNumber))] pageText
        ]

one :: Int -> Page
one = { number: 1, size: _ } 
