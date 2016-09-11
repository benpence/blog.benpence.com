module Blog.Pages exposing ( one, Page, PageOptions, view )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

type alias Page = {
    page : Int,
    pageSize : Int
}

type alias PageOptions = { 
    title : String,
    totalPages : Int,
    currentPage : Int
}

one : Int -> Page
one pageSize = { page = 1, pageSize = pageSize }

view : (Int -> a) -> PageOptions -> Html a
view pageEvent options =
    nav [] [
        viewPages pageEvent options.title options.currentPage [1..options.totalPages]
    ]

viewPages : (Int -> a) -> String -> Int -> List Int -> Html a
viewPages pageEvent title currentPage pageNumbers =
  let
    pages = List.map (viewPage pageEvent currentPage) pageNumbers
    titleItem = li [] [span [class "page-title"] [text title]]
  in
    ul [class "pagination"] (titleItem :: pages)

viewPage : (Int -> a) -> Int -> Int -> Html a
viewPage pageEvent currentPage pageNumber =
    if currentPage == pageNumber then
        li [class "active"] [
            a []                               [text (toString pageNumber)]
        ]
    else
        li [] [
            a [onClick (pageEvent pageNumber)] [text (toString pageNumber)]
        ]
