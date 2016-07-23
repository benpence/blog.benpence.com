package com.benpence.blog.store

import com.benpence.blog.model.{User, UserId}
import com.twitter.util.Future
import com.twitter.storehaus.{ConcurrentHashMapStore, QueryableStore, ReadableStore, Store}
import scala.collection.JavaConverters._

sealed trait UserQuery  
object UserQuery {
  case object All extends UserQuery
  case class ByEmail(email: String) extends UserQuery
}

trait UserStore extends Store[UserId, User] with QueryableStore[UserQuery, User]

class MemoryUserStore extends ConcurrentHashMapStore[UserId, User] with UserStore {

  class MemoryUserQuerableStore extends ReadableStore[UserQuery, Seq[User]] {
    override def get(query: UserQuery): Future[Option[Seq[User]]] = {
      val db = jstore.asScala
  
      val result: Seq[User] = query match {
        case UserQuery.All => db.values.flatten.toSeq
        case UserQuery.ByEmail(email) =>
          db
            .collect { case (_, Some(user)) if user.email.toLowerCase == email.toLowerCase => user }
            .toSeq
      }
  
      Future.value(Some(result))
    }
  }

  override val queryable = new MemoryUserQuerableStore
}
