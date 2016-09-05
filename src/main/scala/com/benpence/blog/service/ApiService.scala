package com.benpence.blog.service

import com.benpence.blog.model.{ApiUser, ApiPost, Post, PostId, User, UserId}
import com.benpence.blog.store.{PostQuery, PostStore, UserStore}
import com.benpence.blog.util.Clock
import com.benpence.blog.util.PrimitiveEnrichments._
import com.twitter.util.Future

trait ApiService {
  def searchPosts(queryString: String, pageSize: Int, page: Int): Future[Seq[ApiPost]]
  def postsByTag(tag: String, pageSize: Int, page: Int): Future[Seq[ApiPost]]
  def postById(postId: PostId): Future[Option[ApiPost]]
}

class StoreApiService(
  val postStore: PostStore,
  val userStore: UserStore
) extends ApiService {

  override def searchPosts(queryString: String, pageSize: Int, page: Int): Future[Seq[ApiPost]] = {
    postStore.queryable
      .get(PostQuery.Search(queryString))
      .flatMap { case Some(posts) =>
        val outputPosts = paginated(posts, pageSize, page)
        Future.collect(outputPosts.map(hydratePost))
      }
  }

  override def postsByTag(tag: String, pageSize: Int, page: Int): Future[Seq[ApiPost]] = {
    postStore.queryable
      .get(PostQuery.ByTag(tag))
      .flatMap { case Some(posts) =>
        val outputPosts = paginated(posts, pageSize, page)
        Future.collect(outputPosts.map(hydratePost))
      }
  }

  def postById(postId: PostId): Future[Option[ApiPost]] = {
    postStore
      .get(postId)
      .flatMap {
        case Some(post) => hydratePost(post).map(Some(_))
        case None => Future.value(None)
      }
  }

  private[service] def paginated[A](list: Seq[A], pageSize: Int, page: Int): Seq[A] = {
    list.drop((page - 1) * pageSize).take(pageSize)
  }

  private[service] def hydratePost(post: Post): Future[ApiPost] = {
    userStore.get(post.author).map {
      case Some(user) => ApiPost.from(post, ApiUser.from(user))
      // Throw exception
      case None => ???
    }
  }
}
