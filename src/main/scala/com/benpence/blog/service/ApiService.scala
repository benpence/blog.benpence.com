package com.benpence.blog.service

import com.benpence.blog.store.PostStore
import com.twitter.finatra.request.RouteParam
import com.twitter.finatra.validation.Size
import com.twitter.util.{Future, NonFatal}

sealed trait ApiResponse

sealed case class Successful[T](results: T) extends ApiResponse

sealed class ApiError(val error: String) extends ApiResponse
case object InternalError extends ApiError("Internal Server Error")
sealed case class InvalidPostId(id: String) extends ApiError(s"Invalid post id: '$id'")
sealed case class ParameterConstraint(constraint: String) extends ApiError(constraint)

object ApiService {
  val liftInternalError: PartialFunction[Throwable, ApiResponse] = {
    case NonFatal(t) => {
      // logger.error(...)
      InternalError
    }
  }
}

class ApiService(val postStore: PostStore) {
  import ApiService._

  def postAll: Future[ApiResponse] = {
    postStore
      .all
      .map(Successful(_))
      .handle(liftInternalError)
  }

  def postId(request: PostIdRequest): Future[ApiResponse] = {
    postStore 
      .getById(request.id)
      .map {
        case Some(post) => Successful(post)
        case None => InvalidPostId(request.id)
      }
      .handle(liftInternalError)
  }

  def postQuery(request: PostQueryRequest): Future[ApiResponse] = {
    postStore
      .query(request.q)
      .map(Successful(_))
      .handle(liftInternalError)
  }
}

case class PostIdRequest(
  @Size(min = 1, max = 20)
  @RouteParam
  id: String
)

case class PostQueryRequest(
  @Size(min = 1, max = 100)
  @RouteParam
  q: String
)
