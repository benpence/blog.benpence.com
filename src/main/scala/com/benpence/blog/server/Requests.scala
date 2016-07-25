package com.benpence.blog.server

import com.twitter.finatra.request.{ForumParam, QueryParam, RouteParam}
import com.twitter.finatra.validation.Size

case class MostRecentPostsRequest(
  @QueryParam
  pageSize: Int,

  @QueryParam
  page: Int
)

case class PostsByAuthorRequest(
  @RouteParam
  userId: Long
)

case class PostsByTagRequest(
  @RouteParam
  tag: String
)

case class PostsContainingRequest(
  @QueryParam
  queryString: String
)

case class PostRequest(
  @RouteParam
  postId: Long
)

case class NewLoginRequest(
  @ForumParam
  csrf: String,

  @ForumParam
  email: String,

  @ForumParam
  password: String
)
