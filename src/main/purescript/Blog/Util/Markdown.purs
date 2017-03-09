module Blog.Util.Markdown
  ( Action(..)
  , toPux
  ) where

import Data.Either (Either)
import Data.Foldable (foldl)
import Data.List (List)
import Data.Maybe (fromMaybe)
import Pux.Html (Html)
import Prelude

import Data.List                                 as List
import Pux.Html                                  as H
import Pux.Html.Attributes                       as A
import Text.Markdown.SlamDown                    as S
import Text.Markdown.SlamDown.Parser             as Parser

data Action
    -- | URL of clicked link
    = Clicked String


toPux :: String -> Either String (Html Action)
toPux markdown =
  let
    blocksToPux :: S.SlamDownP String -> Html Action
    blocksToPux = H.div [] <<< toArray <<< map blockToPux <<< (\(S.SlamDown bs) -> bs)
  in
    --map blocksToPux parsed
    map blocksToPux (Parser.parseMd markdown)

blockToPux :: S.Block String -> Html Action
blockToPux block = case block of
    S.Rule -> H.hr [] []
    (S.LinkReference label url) -> H.a [A.href url] [H.text label]
    -- Evaluating blocks unsupported
    (S.CodeBlock _ lines) ->
      let
        code =
            if (List.length lines) == 1
            then toArray (map H.text lines)
            else [H.text (foldl (\a b -> a <> "\n" <> b) "" lines)]
      in
        H.pre [A.className "codeblock"] code
    (S.Lst (S.Bullet  _) items) ->
       H.ul [] (map listItemToPux (toArray (map toArray items)))
    (S.Lst (S.Ordered _) items) ->
       H.ol [] (map listItemToPux (toArray (map toArray items)))
    (S.Blockquote blocks) ->
       H.div [A.className "blockquote"] (toArray (map blockToPux  blocks))
    (S.Header 1 inlines) -> H.h1 [] (inlinesToPux inlines)
    (S.Header 2 inlines) -> H.h2 [] (inlinesToPux inlines)
    (S.Header 3 inlines) -> H.h3 [] (inlinesToPux inlines)
    (S.Header 4 inlines) -> H.h4 [] (inlinesToPux inlines)
    (S.Header 5 inlines) -> H.h5 [] (inlinesToPux inlines)
    (S.Header _ inlines) -> H.h6 [] (inlinesToPux inlines)
    (S.Paragraph inlines) -> H.p [] (inlinesToPux inlines)
  where
    inlinesToPux :: List (S.Inline String) -> Array (Html Action)
    inlinesToPux = toArray <<< map inlineToPux <<< collapseText

listItemToPux :: Array (S.Block String) -> Html Action
listItemToPux blocks = H.li [] (map blockToPux blocks)

inlineToPux :: S.Inline String -> Html Action
inlineToPux inline = case inline of
    -- Creating forms unsupported
    (S.FormField _ _ _) -> H.div [] []
    (S.Image inlines url) -> H.img [A.src url] (inlinesToPux inlines)
    (S.Link inlines (S.InlineLink url)) ->
        H.a [A.href url] (inlinesToPux inlines)
    -- TODO: Why is this maybe?
    (S.Link inlines (S.ReferenceLink maybeUrl)) ->
        H.a [A.href (fromMaybe "" maybeUrl)] (inlinesToPux inlines)
    -- Evaluating code unsupported
    (S.Code _ code) -> H.span [A.className "code"] [H.text code]
    (S.Strong inlines) -> H.strong [] (inlinesToPux inlines)
    (S.Emph inlines) -> H.em [] (inlinesToPux inlines)
    S.LineBreak -> H.text "\n"
    S.SoftBreak -> H.text ""
    S.Space -> H.text " "
    -- TODO: HTML escape sequence
    (S.Entity text) -> H.text text
    (S.Str text) -> H.text text
  where
    inlinesToPux :: List (S.Inline String) -> Array (Html Action)
    inlinesToPux = toArray <<< map inlineToPux <<< collapseText

collapseText :: List (S.Inline String) -> List (S.Inline String)
collapseText =
  let
    combine :: List (S.Inline String) -> S.Inline String -> List (S.Inline String)
    combine (List.Cons (S.Str acc) tail) (S.Str e) =
        List.Cons (S.Str (acc <> e)) tail
    combine (List.Cons (S.Str acc) tail) S.Space =
        List.Cons (S.Str (acc <> " ")) tail
    combine acc e = List.Cons e acc
  in
    foldl combine List.Nil

toArray :: forall a. List a -> Array a
toArray = List.toUnfoldable
