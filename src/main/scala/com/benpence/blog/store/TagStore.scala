package com.benpence.blog.store

import com.benpence.blog.model.{Tag, TagId, Post, PostId}
import com.twitter.storehaus.{ConcurrentHashMapStore, QueryableStore, ReadableStore, Store}
import com.twitter.util.Future
import scala.collection.JavaConverters._

case class TaggedPosts(tag: TagId, postIds: Set[PostId])
trait TaggedPostsStore extends Store[TagId, TaggedPosts]
class MemoryTaggedPostsStore extends ConcurrentHashMapStore[TagId, TaggedPosts] with TaggedPostsStore

sealed trait TagQuery
object TagQuery {
  case object All extends TagQuery
}

trait TagStore extends Store[TagId, Tag] with QueryableStore[TagQuery, Tag]
class MemoryTagStore extends ConcurrentHashMapStore[TagId, Tag] with TagStore {
  class MemoryTagQueryableStore extends ReadableStore[TagQuery, Seq[Tag]] {
    override def get(query: TagQuery): Future[Option[Seq[Tag]]] = {
      val db = jstore.asScala

      val result = query match {
        case TagQuery.All =>
          db
            .iterator
            .map(_._2)
            .flatten
            .toList
      }

      Future.value(Some(result))
    }
  }

  override val queryable = new MemoryTagQueryableStore
}
