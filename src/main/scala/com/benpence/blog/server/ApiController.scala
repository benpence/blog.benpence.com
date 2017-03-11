package com.benpence.blog.server

import com.benpence.blog.model.{PostId, UserId}
import com.benpence.blog.service.ApiService
import com.benpence.blog.util.Markdown
import com.benpence.blog.util.PrimitiveEnrichments._
import com.twitter.finagle.http.Response
import com.twitter.finatra.http.Controller
import com.twitter.finatra.http.response.ResponseBuilder
import com.twitter.util.{Future, NonFatal}
import java.net.URLDecoder

sealed trait ApiResponse[T]

sealed case class Successful[T](results: T) extends ApiResponse[T]

sealed class ApiError(val errors: String*) extends ApiResponse[Nothing]
case object InternalError extends ApiError("Internal Server Error")
case class InvalidPostId(id: Long) extends ApiError(s"Invalid post_id: '$id'")
case class InvalidUserId(id: Long) extends ApiError(s"Invalid user_id: '$id'")
case class ParameterConstraint(constraint: String) extends ApiError(constraint)

class ApiController(apiService: ApiService) extends Controller {
  import ApiResponse._

  get("/api/post/search") { request: PostsSearchRequest =>
    val queryString = URLDecoder.decode(request.queryString, "UTF8")

    apiService
      .searchPosts(queryString, request.pageSize, request.page)
      .map(Successful(_))
      .toResponse(response)
  }

  get("/api/post/by_tag") { request: PostsByTagRequest =>
    apiService
      .postsByTag(request.tag, request.pageSize, request.page)
      .map(Successful(_))
      .toResponse(response)
  }


  get("/api/post/by_id") { request: PostRequest =>
    apiService
      .postById(PostId(request.postId))
      .map {
        case Some(apiPost) => Successful(apiPost)
        case None => InvalidPostId(request.postId)
      }
      .toResponse(response)
  }

  get("/api/tagcounts") { request: TagCountsRequest =>
    apiService
      .tagCounts
      .map(Successful(_))
      .toResponse(response)
  }

  get("/api/about") { request: AboutRequest =>
    apiService
      .about
      .flatMap { aboutContent => Markdown.parse(aboutContent).toFuture }
      .map(Successful(_))
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
