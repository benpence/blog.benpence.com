package com.benpence.blog.server

import com.benpence.blog.service.PostService
import com.benpence.blog.store.{MemoryPostStore, MemoryUserStore}
import com.twitter.finagle.http.{Request, Response}
import com.twitter.finatra.http.HttpServer
import com.twitter.finatra.http.filters.{CommonFilters, LoggingMDCFilter, TraceIdMDCFilter}
import com.twitter.finatra.http.routing.HttpRouter

case class HiRequest(
  id: Long,
  name: String
)

object BlogServerMain extends BlogServer

class BlogServer extends HttpServer {

  override def configureHttp(router: HttpRouter) {
    router
      .filter[LoggingMDCFilter[Request, Response]]
      .filter[TraceIdMDCFilter[Request, Response]]
      .filter[CommonFilters]
      .add(
        new ApiController(
          new PostService(
            new MemoryPostStore,
            new MemoryUserStore
          )
        )
      )
      .add[StaticController]
  }
}
