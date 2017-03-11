package com.benpence.blog.model

import com.benpence.blog.util.Markdown

case class UserId(asLong: Long) extends AnyVal
case class User(
  id: UserId,
  name: String,
  email: String,
  passwordHash: String,
  isAdmin: Boolean,
  createdMillis: Long
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
    author,
    post.title,
    post.createdMillis,
    post.tags,
    // TODO: Cache this
    Markdown.parse(post.content).get
  )
}
case class ApiPost(
  id: PostId,
  author: ApiUser,
  title: String,
  createdMillis: Long,
  tags: Set[String],
  content: Seq[Markdown.Component]
)

case class ApiPosts(
  totalPages: Int,
  posts: Seq[ApiPost]
)

case class TagId(asLong: Long) extends AnyVal
case class Tag(id: TagId, name: String)
case class TagCount(tag: String, count: Long)

case class Cookie(asString: String) extends AnyVal
case class Login(cookie: Cookie, userId: UserId, timeLoggedInMillis: Long)
