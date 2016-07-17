package com.benpence.blog.server

import com.benpence.blog.model.Post
import com.benpence.blog.service._
import com.twitter.finagle.http.Request
import com.twitter.finagle.http.Response
import com.twitter.finatra.http.Controller
import com.twitter.finatra.http.response.ResponseBuilder
import com.twitter.util.{Future, NonFatal, Return, Throw}

class ApiController(apiService: ApiService) extends Controller {
  import FutureEnrichments._

  get("/api/post/all") { _: Request =>
    apiService 
      .postAll
      .toResponse(response)
  }

  get("/api/post/id/:id") { request: PostIdRequest =>
    apiService 
      .postId(request)
      .toResponse(response)
  }

  get("/api/post/query/:q") { request: PostQueryRequest =>
    apiService 
      .postQuery(request)
      .toResponse(response)
  }
}

object FutureEnrichments {
  implicit class RichFuture[A](val future: Future[A]) extends AnyVal {
    // TODO: Fix this type signature to be something like A =:= ApiResponse
    def toResponse[A <: ApiResponse](implicit response: ResponseBuilder): Future[Response] = {
      future
        .map {
          case s @ Successful(_) => response.ok.json(s)
          case e: ApiError => response.notFound.json(new ApiError(e.error))
        }
        .handle {
          // TODO: logger.error(t)
          case NonFatal(e) => response.internalServerError.json(InternalError)
        }
    }
  }
}
