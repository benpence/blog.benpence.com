package com.benpence.blog.server

import com.benpence.blog.service.PostService
import com.benpence.blog.store.{MemoryPostStore, MemoryUserStore, Posts, Users}
import com.benpence.blog.util.UriLoader
import com.benpence.blog.util.ArgsEnrichments._
import com.benpence.blog.util.PrimitiveEnrichments._
import com.twitter.finagle.http.{Request, Response}
import com.twitter.finatra.http.HttpServer
import com.twitter.finatra.http.filters.{CommonFilters, LoggingMDCFilter, TraceIdMDCFilter}
import com.twitter.finatra.http.routing.HttpRouter
import com.twitter.scalding.Args
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

  val PostsFileArg = "file.posts"
  val UsersFileArg = "file.users"

  def main(argv: Array[String]): Unit = {
    val (blogArgs, finatraArgs) = (argv.takeWhile(_ != "--"), argv.dropWhile(_ != "--").drop(1))
    val args = Args(blogArgs)
    val usersYaml = Source.fromFile(args.existingFile(UsersFileArg)).mkString
    val postsYaml = Source.fromFile(args.existingFile(PostsFileArg)).mkString

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

    server.main(finatraArgs)
  }
}
