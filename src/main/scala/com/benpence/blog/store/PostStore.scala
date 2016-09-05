package com.benpence.blog.store

import com.benpence.blog.model.{Post, PostId, User, UserId}
import com.twitter.storehaus.{ConcurrentHashMapStore, QueryableStore, ReadableStore, Store}
import com.twitter.util.Future
import scala.collection.JavaConverters._

sealed trait PostQuery
object PostQuery {
  case class Search(queryString: String) extends PostQuery
  case class ByTag(tag: String) extends PostQuery
}


trait PostStore extends Store[PostId, Post] with QueryableStore[PostQuery, Post]

class MemoryPostStore extends ConcurrentHashMapStore[PostId, Post] with PostStore {
  class MemoryPostQueryableStore extends ReadableStore[PostQuery, Seq[Post]] {
    override def get(query: PostQuery): Future[Option[Seq[Post]]] = {
      val db = jstore.asScala

      val result = query match {
        case PostQuery.Search(queryString) =>
          db
            .iterator
            // TODO: Expand
            .collect { case (_, Some(post)) if post.content.contains(queryString) => post }
            .toList
            .sortBy(_.createdMillis)
        case PostQuery.ByTag(tag: String) =>
          db
            .iterator
            .collect { case (_, Some(post)) if post.tags.contains(tag) => post }
            .toList
      }

      Future.value(Some(result))
    }
  }

  override val queryable = new MemoryPostQueryableStore
}
