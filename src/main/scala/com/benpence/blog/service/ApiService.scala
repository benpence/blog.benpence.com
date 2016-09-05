package com.benpence.blog.service

import com.benpence.blog.model._
import com.benpence.blog.store._
import com.benpence.blog.util.Clock
import com.benpence.blog.util.PrimitiveEnrichments._
import com.twitter.util.Future

trait ApiService {
  def searchPosts(queryString: String, pageSize: Int, page: Int): Future[Seq[ApiPost]]
  def postsByTag(tag: String, pageSize: Int, page: Int): Future[Seq[ApiPost]]
  def postById(postId: PostId): Future[Option[ApiPost]]
  def tagCounts: Future[Seq[TagCount]]
}

class StoreApiService(
  val postStore: PostStore,
  val userStore: UserStore,
  val tagStore: TagStore,
  val taggedPostsStore: TaggedPostsStore
) extends ApiService {

  override def searchPosts(queryString: String, pageSize: Int, page: Int): Future[Seq[ApiPost]] = {
    postStore.queryable
      .get(PostQuery.Search(queryString))
      .flatMap { case Some(posts) =>
        val outputPosts = paginated(posts, pageSize, page)
        Future.collect(outputPosts.map(hydratePost))
      }
  }

  override def postById(postId: PostId): Future[Option[ApiPost]] = {
    postStore
      .get(postId)
      .flatMap {
        case Some(post) => hydratePost(post).map(Some(_))
        case None => Future.value(None)
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

  override def tagCounts: Future[Seq[TagCount]] = {
    tagStore.queryable
      .get(TagQuery.All)
      .flatMap { case Some(tags) =>
        val taggedPosts = tags.map { tag =>
          taggedPostsStore
            .get(tag.id)
            .map { case Some(taggedPosts) => TagCount(tag.name, taggedPosts.postIds.size) }
        }

        Future.collect(taggedPosts)
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
