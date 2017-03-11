module Blog.Types
  ( Component(..)
  , Page
  , Post
  , PostId(..)
  , User
  , UserId(..)
  , Tag
  , TagCount
  ) where

import Data.Tuple (Tuple)

type Page =
  { number :: Int
  , size   :: Int
  }

type PostId = Int

type Post =
  { id            :: PostId
  , author        :: User
  , title         :: String
  , createdMillis :: Number
  , tags          :: Array Tag
  , content       :: Array Component
  }

type UserId = Int

type User =
  { id   :: UserId
  , name :: String
  }

type Tag =
  { name :: String
  }

type TagCount =
  { tag :: Tag
  , count :: Int
  }

newtype Component = Component
  { component :: String
  , children :: Array Component
  , attributes :: Array (Tuple String String)
  }
