module Blog.Util.Markdown
  ( toPux
  ) where

import Blog.Types (Component(..))
import Data.Foldable (find, foldl)
import Data.List (List)
import Data.Maybe (fromMaybe)
import Data.Tuple (Tuple(..))
import Pux.Html (Html)
import Prelude

import Data.Array                                as Array
import Data.List                                 as List
import Data.Tuple                                as Tuple
import Pux                                       as Pux
import Pux.Html                                  as H
import Pux.Html.Attributes                       as A

toPux :: forall a. Component -> Html a
toPux (Component { component, children, attributes }) =
  let
    attributes' = map toAttribute (Array.filter (("content" /= _) <<< Tuple.fst) attributes)
    children' = map toPux children

    content = fromMaybe "" (map Tuple.snd (find (("content" == _) <<< Tuple.fst) attributes))

    puxConstructor :: forall a. Array (H.Attribute a) -> Array (Html a) -> Html a
    puxConstructor = case component of
        "p"          -> H.p
        "h1"         -> H.h1
        "h2"         -> H.h2
        "h3"         -> H.h3
        "h4"         -> H.h4
        "h5"         -> H.h5
        "h6"         -> H.h6
        "link"       -> H.a
        "blockquote" -> H.blockquote
        "codeblock"  -> H.pre
        "hr"         -> H.hr
        "li"         -> H.li
        "html"       -> \_ _ -> H.text content
        "ol"         -> H.ol
        "ul"         -> H.ul
        "text"       -> \_ _ -> H.text content
        "code"       -> \_ _ -> H.code [] [H.text content]
        "string"     -> H.strong
        "emphasis"   -> H.em
        "a"          -> H.a
        "img"        -> H.img
        _            -> \_ _ -> H.text content
  in
    puxConstructor attributes' children'

toAttribute :: forall a. Tuple String String -> H.Attribute a
toAttribute (Tuple key val) = A.alt "hhh"
