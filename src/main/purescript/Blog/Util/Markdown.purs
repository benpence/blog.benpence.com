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
    blocksToPux = H.div [] <<< map blockToPux <<< toArray <<< (\(S.SlamDown bs) -> bs)
  in
    --map blocksToPux parsed
    map blocksToPux (Parser.parseMd markdown)

blockToPux :: S.Block String -> Html Action
blockToPux S.Rule = H.hr [] []
blockToPux (S.LinkReference label url) = H.a [A.href url] [H.text label]
-- Evaluating blocks unsupported
blockToPux (S.CodeBlock _ lines) =
  let
    code =
        if (List.length lines) == 1
        then map H.text (toArray lines)
        else [H.text (foldl (\a b -> a <> "\n" <> b) "" lines)]
  in
    H.pre [A.className "codeblock"] code
blockToPux (S.Lst (S.Bullet  _) items) =
    H.ul [] (map listItemToPux (toArray (map toArray items)))
blockToPux (S.Lst (S.Ordered _) items) =
    H.ol [] (map listItemToPux (toArray (map toArray items)))
blockToPux (S.Blockquote blocks) =
    H.div [A.className "blockquote"] (map blockToPux (toArray blocks))
blockToPux (S.Header 1 inlines) = H.h1 [] (map inlineToPux (toArray inlines))
blockToPux (S.Header 2 inlines) = H.h2 [] (map inlineToPux (toArray inlines))
blockToPux (S.Header 3 inlines) = H.h3 [] (map inlineToPux (toArray inlines))
blockToPux (S.Header 4 inlines) = H.h4 [] (map inlineToPux (toArray inlines))
blockToPux (S.Header 5 inlines) = H.h5 [] (map inlineToPux (toArray inlines))
blockToPux (S.Header _ inlines) = H.h6 [] (map inlineToPux (toArray inlines))
blockToPux (S.Paragraph inlines) = H.p [] (map inlineToPux (toArray inlines))

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
    inlinesToPux = map inlineToPux <<< toArray

toArray :: forall a. List a -> Array a
toArray = List.toUnfoldable
