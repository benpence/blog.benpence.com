package com.benpence.blog.server

import com.benpence.blog.model.{PostId, UserId}
import com.benpence.blog.service.PostService
import com.twitter.finagle.http.Response
import com.twitter.finatra.http.Controller
import com.twitter.finatra.http.response.ResponseBuilder
import com.twitter.util.{Future, NonFatal}

sealed trait ApiResponse[T]

sealed case class Successful[T](results: T) extends ApiResponse[T]

sealed class ApiError(val errors: String*) extends ApiResponse[Nothing]
case object InternalError extends ApiError("Internal Server Error")
case class InvalidPostId(id: Long) extends ApiError(s"Invalid post_id: '$id'")
case class InvalidUserId(id: Long) extends ApiError(s"Invalid user_id: '$id'")
case class ParameterConstraint(constraint: String) extends ApiError(constraint)

class ApiController(postService: PostService) extends Controller {

  import ApiResponse._

  get("/api/post/most_recent") { request: MostRecentPostsRequest =>
    postService
      .mostRecent(request.pageSize, request.page)
      .map(Successful(_))
      .toResponse(response)
  }

  get("/api/post/by_author/:user_id") { request: PostsByAuthorRequest =>
    postService
      .byAuthor(UserId(request.userId))
      .map {
        case Some(apiPosts) => Successful(apiPosts)
        case None => InvalidUserId(request.userId)
      }
      .toResponse(response)
  }

  get("/api/post/by_tag/:tag") { request: PostsByTagRequest =>
    postService
      .byTag(request.tag)
      .map(Successful(_))
      .toResponse(response)
  }

  get("/api/post/containing/:query_string") { request: PostsContainingRequest =>
    postService
      .containing(request.queryString)
      .map(Successful(_))
      .toResponse(response)
  }

  get("/api/post/by_id/:post_id") { request: PostRequest =>
    postService 
      .apply(PostId(request.postId))
      .map {
        case Some(apiPost) => Successful(apiPost)
        case None => InvalidPostId(request.postId)
      }
      .toResponse(response)
  }
}

object ApiResponse {
  implicit class ResponseFuture(val future: Future[ApiResponse[_]]) extends AnyVal {
    // TODO: Figure out how to get ResponseBuilder injected
    def toResponse(implicit response: ResponseBuilder): Future[Response] = {
      future
        .handle {
          case NonFatal(t) => {
            // logger.error(...)
            InternalError
          }
        }
        .map {
          case s @ Successful(_) => response.ok.json(s)
          case InternalError => response.internalServerError.json(InternalError)

          // TODO: JSON configuration to make this unnecessary?
          case e: ApiError => response.badRequest.json(new ApiError(e.errors:_*))
        }
    }
  }
}
