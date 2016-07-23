package com.benpence.blog.model

case class UserId(asLong: Long) extends AnyVal
case class User(
  id: UserId,
  name: String,
  email: String,
  passwordHash: String,
  isAdmin: Boolean,
  timeCreatedMillis: Long
)
object ApiUser {
  def from(user: User): ApiUser = ApiUser(user.id, user.name)
}
case class ApiUser(
  id: UserId,
  name: String
)

case class PostId(asLong: Long) extends AnyVal
case class Post(
  id: PostId,
  author: UserId,
  title: String,
  createdMillis: Long,
  tags: Set[String],
  content: String
)
object ApiPost {
  def from(post: Post, author: ApiUser): ApiPost = ApiPost(
    post.id,
    author: ApiUser,
    post.title: String,
    post.createdMillis: Long,
    post.tags: Set[String],
    post.content: String
  )
}
case class ApiPost(
  id: PostId,
  author: ApiUser,
  title: String,
  createdMillis: Long,
  tags: Set[String],
  content: String
)

case class Cookie(asString: String) extends AnyVal
case class Login(cookie: Cookie, userId: UserId, timeLoggedInMillis: Long)
