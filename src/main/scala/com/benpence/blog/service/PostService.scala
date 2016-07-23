package com.benpence.blog.service

import com.benpence.blog.model.{ApiUser, ApiPost, Post, PostId, User, UserId}
import com.benpence.blog.store.{PostQuery, PostStore, UserStore}
import com.benpence.blog.util.Clock
import com.benpence.blog.util.FutureEnrichments._
import com.twitter.util.Future

class PostService(
  val postStore: PostStore,
  val userStore: UserStore
) {

  def mostRecent(pageSize: Int, page: Int): Future[Seq[ApiPost]] = {
    postStore.queryable
      .get(PostQuery.MostRecent(pageSize, page))
      .flatMap { case Some(posts) => Future.collect(posts.map(hydratePost)) }
  }

  def byAuthor(userId: UserId): Future[Option[Seq[ApiPost]]] = {
    userStore
      .get(userId)
      .flatMap {
        case Some(user) =>
          postStore.queryable
            .get(PostQuery.ByAuthor(userId))
            .map { case Some(posts) =>
              Some(posts.map { post =>
                ApiPost.from(post, ApiUser.from(user))
              })
            }
        case None => Future.value(None)
      }
  }

  def byTag(tag: String): Future[Seq[ApiPost]] = {
    postStore.queryable
      .get(PostQuery.ByTag(tag))
      .flatMap { case Some(posts) => Future.collect(posts.map(hydratePost)) }
  }

  def containing(queryString: String): Future[Seq[ApiPost]] = {
    postStore.queryable
      .get(PostQuery.Containing(queryString))
      .flatMap { case Some(posts) => Future.collect(posts.map(hydratePost)) }
  }

  def apply(postId: PostId): Future[Option[ApiPost]] = {
    postStore
      .get(postId)
      .flatMap {
        case Some(post) => hydratePost(post).map(Some(_))
        case None => Future.value(None)
      }
  }

  private[service] def hydratePost(post: Post): Future[ApiPost] = {
    userStore.get(post.author).map {
      case Some(user) => ApiPost.from(post, ApiUser.from(user))
      // Throw exception
      case None => ???
    }
  }
}
