package com.benpence.blog.server

import com.benpence.blog.service.ApiService
import com.benpence.blog.store.InMemoryPostStore
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
      .add(new ApiController(new ApiService(InMemoryPostStore(Set.empty))))
  }
}
