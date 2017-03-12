module Blog.Util.Markdown
  ( toPux
  ) where

import Blog.Types (Component(..))
import Data.Foldable (find)
import Data.Maybe (fromMaybe)
import Data.Tuple (Tuple(..))
import Pux.Html (Html)
import Prelude

import Data.Array                                as Array
import Data.Tuple                                as Tuple
import Pux.Html                                  as H
import Pux.Html.Attributes                       as A

toPux :: forall a. Component -> Html a
toPux (Component { component, children, attributes }) =
  let
    attributes' = join (map toAttribute (Array.filter (("content" /= _) <<< Tuple.fst) attributes))
    children' = map toPux children

    content = fromMaybe "" (map Tuple.snd (find (("content" == _) <<< Tuple.fst) attributes))

    puxConstructor :: Array (H.Attribute a) -> Array (Html a) -> Html a
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

toAttribute :: forall a. Tuple String String -> Array (H.Attribute a)
toAttribute (Tuple "id"      val) = [A.id_ val]
toAttribute (Tuple "href"    val) = [A.href val]
toAttribute (Tuple "alt"     val) = [A.alt val]
toAttribute (Tuple "src"     val) = [A.src val]
toAttribute _                     = []
