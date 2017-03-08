module Blog.Types
  ( Page
  , Post
  , PostId(..)
  , User
  , UserId(..)
  , Tag
  , TagCount
  ) where

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
  , content       :: String
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
