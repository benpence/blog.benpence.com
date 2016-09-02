package com.benpence.blog.store

import com.benpence.blog.model.{Post, PostId, User, UserId}
import com.benpence.blog.util.{UriLoader, TryUtils}
import com.benpence.blog.util.PrimitiveEnrichments._
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import java.util.{List => JList}
import scala.collection.JavaConverters._
import scala.util.Try

case class UriParseException(uri: String)
  extends RuntimeException(s"Failed to parse URI '$uri'")
case class UnsupportedException(`type`: String, key: String, options: Seq[String])
  extends RuntimeException(s"Unsupported ${`type`}: $key. Options are $options")

case class PostContent(
  uri: String
)

case class PostMetaData(
  id: Long,
  author: Long,
  title: String,
  createdMillis: Long,
  tags: Seq[String],
  content: PostContent
)

case class UserDatum(
  id: Long,
  name: String,
  email: String,
  passwordHash: String,
  isAdmin: Boolean,
  createdMillis: Long
)

object Users {
  /*
   * Expects YAML to be list of
   *
   *   id: 1
   *   name: Ben Pence
   *   email: ben@example.com
   *   passwordHash: password
   *   isAdmin: true
   *   createdMillis: 30233038
   */
  def fromYaml(yaml: String): Try[Seq[User]] = {
    val yamlMapper = new ObjectMapper(new YAMLFactory)
    yamlMapper.registerModule(DefaultScalaModule)

    val `type` = yamlMapper.getTypeFactory.constructCollectionType(classOf[JList[_]], classOf[UserDatum])
    Try {
      val list: JList[UserDatum] = yamlMapper.readValue(yaml, `type`)
      list
    }.map { data =>
      data.asScala.map { datum =>
        User(
          id = UserId(datum.id),
          name = datum.name,
          email = datum.email,
          passwordHash = datum.passwordHash,
          isAdmin = datum.isAdmin,
          createdMillis = datum.createdMillis
        )
      }
    }
  }
}

object Posts {
  /*
   * Expects YAML to be list of
   *
   *   id: 1
   *   author: 0
   *   title: Winter Coming :)
   *   createdMillis: 1471202213000
   *   tags:
   *     - winter
   *     - beasts
   *   content:
   *     uri: file://data/posts/bloo.md
   */
  def fromYaml(
    yaml: String
  )(
    implicit
    uriLoaders: Map[String, UriLoader]
  ): Try[Seq[Post]] = {
    val yamlMapper = new ObjectMapper(new YAMLFactory)
    yamlMapper.registerModule(DefaultScalaModule)

    fromMetadata(yaml, yamlMapper)
  }

  private def fromMetadata(
    content: String,
    mapper: ObjectMapper
  )(
    implicit
    uriLoaders: Map[String, UriLoader]
  ): Try[Seq[Post]] = {

    Try {
      val `type` = mapper.getTypeFactory.constructCollectionType(classOf[JList[_]], classOf[PostMetaData])
      val list: JList[PostMetaData] = mapper.readValue(content, `type`)
      list.asScala

    }.flatMap { postMetadatas =>
      val postTrys = postMetadatas.map { metadata =>
        for {
          (loaderStr, path) <- UriLoader
            .parseLoaderAndPath(metadata.content.uri)
            .toTry(UriParseException(metadata.content.uri))
          loader <- uriLoaders
            .get(loaderStr)
            .toTry(UnsupportedException(
              "URI loader",
              metadata.content.uri,
              uriLoaders.keys.toSeq))
          content <- loader.load(path)
        } yield Post(
          id = PostId(metadata.id),
          author = UserId(metadata.author),
          title = metadata.title,
          createdMillis = metadata.createdMillis,
          tags = metadata.tags.toSet,
          content = content
        )
      }

      TryUtils.sequence(postTrys)
    }
  }
}
