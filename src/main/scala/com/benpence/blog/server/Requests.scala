package com.benpence.blog.server

import com.twitter.finatra.request.{QueryParam, RouteParam}
import com.twitter.finatra.validation.Size

case class PostsSearchRequest(
  @QueryParam
  queryString: String,

  @QueryParam
  pageSize: Int,

  @QueryParam
  page: Int
)

case class PostsByTagRequest(
  @QueryParam
  tag: String,

  @QueryParam
  pageSize: Int,

  @QueryParam
  page: Int
)

case class PostRequest(
  @QueryParam
  postId: Long
)

case class TagCountsRequest(
)
