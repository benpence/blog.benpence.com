package com.benpence.blog.server

import com.twitter.finagle.http.Request
import com.twitter.finatra.http.Controller

/**
  * Serves static file content. One of these flags must be set:
  *   "doc.root"       classpath resources
  *   "local.doc.root" filesystem resources
  */
class StaticController extends Controller {

  get("/static/:*") { request: Request =>
    // Responds with Status.NotFound when file is not in JAR/filesystem
    response.ok.file(request.path)
  }

  // Let the front-end handle the path
  get("/:*") { request: Request =>
    response.ok.file("/static/index.html")
  }
}
