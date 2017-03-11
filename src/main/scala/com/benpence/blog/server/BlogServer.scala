package com.benpence.blog.server

import com.benpence.blog.model.{Tag, TagId}
import com.benpence.blog.service.StoreApiService
import com.benpence.blog.store._
import com.benpence.blog.util.UriLoader
import com.benpence.blog.util.ResourceLoader
import com.benpence.blog.util.ArgsEnrichments._
import com.benpence.blog.util.PrimitiveEnrichments._
import com.twitter.finagle.http.{Request, Response}
import com.twitter.finatra.http.HttpServer
import com.twitter.finatra.http.filters.{CommonFilters, LoggingMDCFilter, TraceIdMDCFilter}
import com.twitter.finatra.http.routing.HttpRouter
import com.twitter.storehaus.Store
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
  val AboutResource = "/web/static/About.md"

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
    val tagStore = new MemoryTagStore
    val taggedPostsStore = new MemoryTaggedPostsStore
    Await.result {
      Posts
        .fromYaml(postsYaml)
        .toFuture
        .flatMap { posts =>
          val (tags, taggedPostss) = posts.flatMap { post =>
            post.tags.map { tag => (tag, post.id) }
          }
          .groupBy(_._1)
          .zipWithIndex
          .map { case ((name, postIds), id) =>
              val tagId = TagId(id)
              (Tag(tagId, name), TaggedPosts(tagId, postIds.map(_._2).toSet))
          }
          .unzip

          def write[K, V](store: Store[K, V], vs: Seq[V])(k: V => K) = {
            val futures = store.multiPut(vs.map { v => (k(v), Some(v)) }.toMap)
            Future.join(futures.values.toList)
          }

          for {
            _ <- write(postStore, posts)(_.id)
            _ <- write(tagStore, tags.toList)(_.id)
            _ <- write(taggedPostsStore, taggedPostss.toList)(_.tag)
          } yield ()
        }
    }

    val aboutContent = ResourceLoader.load(AboutResource).get

    val server = new BlogServer(
      new ApiController(
        new StoreApiService(
          postStore,
          userStore,
          tagStore,
          taggedPostsStore,
          aboutContent
        )
      )
    )

    server.main(finatraArgs)
  }
}
