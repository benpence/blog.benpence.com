package com.benpence.blog.store

import com.benpence.blog.model.{Post, PostId, User, UserId}
import com.twitter.storehaus.{ConcurrentHashMapStore, QueryableStore, ReadableStore, Store}
import com.twitter.util.Future
import scala.collection.JavaConverters._

sealed trait PostQuery
object PostQuery {
  // TODO: Better pagination abstraction
  case class MostRecent(pageSize: Int, page: Int = 0) extends PostQuery
  case class ByAuthor(userId: UserId) extends PostQuery
  case class ByTag(tag: String) extends PostQuery
  case class Containing(queryString: String) extends PostQuery
}


trait PostStore extends Store[PostId, Post] with QueryableStore[PostQuery, Post]

class MemoryPostStore extends ConcurrentHashMapStore[PostId, Post] with PostStore {
  class MemoryPostQuerableStore extends ReadableStore[PostQuery, Seq[Post]] {
    override def get(query: PostQuery): Future[Option[Seq[Post]]] = {
      val db = jstore.asScala

      val result = query match {
        case PostQuery.MostRecent(pageSize, page) =>
          db
            .map(_._2.get)
            .toList
            .sortBy(_.createdMillis)
            .drop(pageSize * page)
            .take(pageSize)
        case PostQuery.ByAuthor(userId: UserId) =>
          db
            .iterator
            .collect { case (_, Some(post)) if post.author == userId => post }
            .toList
        case PostQuery.ByTag(tag: String) =>
          db
            .iterator
            .collect { case (_, Some(post)) if post.tags.contains(tag) => post }
            .toList
        case PostQuery.Containing(queryString) =>
          db
            .iterator
            // TODO: Expand
            .collect { case (_, Some(post)) if post.content.contains(queryString) => post }
            .toList
      }

      Future.value(Some(result))
    }
  }

  override val queryable = new MemoryPostQuerableStore
}
