package com.benpence.blog.server

import com.benpence.blog.service.PostService
import com.benpence.blog.store.{MemoryPostStore, MemoryUserStore, Posts, Users}
import com.benpence.blog.util.{MarkupLanguage, UriLoader}
import com.benpence.blog.util.PrimitiveEnrichments._
import com.twitter.finagle.http.{Request, Response}
import com.twitter.finatra.http.HttpServer
import com.twitter.finatra.http.filters.{CommonFilters, LoggingMDCFilter, TraceIdMDCFilter}
import com.twitter.finatra.http.routing.HttpRouter
import com.twitter.util.{Await, Future}
import java.io.File
import scala.io.Source

class BlogServer(apiController: ApiController) extends HttpServer {

  override def configureHttp(router: HttpRouter) {
    router
      .filter[LoggingMDCFilter[Request, Response]]
      .filter[TraceIdMDCFilter[Request, Response]]
      .filter[CommonFilters]
      .add(apiController)
      .add[StaticController]
  }
}

object MainBlogServer {
  implicit val supportedUriLoaders = UriLoader.defaults.map { l => (l.name, l) }.toMap
  implicit val supportedMarkupLanguages = MarkupLanguage.defaults.map { l => (l.name, l) }.toMap

  val PostsFileArg = "posts-file"
  val UsersFileArg = "users-file"

  def main(args: Array[String]): Unit = {
    // TODO: val usersFile = args.get(UsersFileArg)
    val usersYaml = Source.fromFile(new File("data/users.yaml")).mkString
    val userStore = new MemoryUserStore
    Await.result {
      Users
        .fromYaml(usersYaml)
        .toFuture
        .flatMap { users =>
          val futures = userStore.multiPut(users.map { user => (user.id, Some(user)) }.toMap)
          Future.join(futures.values.toList)
        }
    }

    // TODO: val postsFile = args.get(PostsFileArg)
    val postsYaml = Source.fromFile(new File("data/posts.yaml")).mkString
    val postStore = new MemoryPostStore
    Await.result {
      Posts
        .fromYaml(postsYaml)
        .toFuture
        .flatMap { posts =>
          val futures = postStore.multiPut(posts.map { post => (post.id, Some(post)) }.toMap)
          Future.join(futures.values.toList)
        }
    }

    val server = new BlogServer(
      new ApiController(
        new PostService(postStore, userStore)
      )
    )

    server.main(args)
  }
}
