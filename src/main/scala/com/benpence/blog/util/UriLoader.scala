package com.benpence.blog.util

import java.io.File
import scala.io.Source
import scala.util.Try

object UriLoader {
  val UriMatcher = """(\w+)://(.+)""".r

  def defaults = Set(
    FileLoader,
    ResourceLoader
  )

  def parseLoaderAndPath(uri: String): Option[(String, String)] = {
    uri match {
      case UriMatcher(loader, path) => Some((loader, path))
      case _ => None
    }
  }
}

sealed trait UriLoader {
  def name: String
  def load(path: String): Try[String]
}

case object ResourceLoader extends UriLoader {
  override val name = "resource"
  override def load(resourcePath: String): Try[String] = {
    Try {
      val inputStream = getClass.getResourceAsStream(resourcePath)
      Source.fromInputStream(inputStream).mkString
    }
  }
}

case object FileLoader extends UriLoader {
  override val name = "file"
  override def load(path: String): Try[String] = {
    Try(Source.fromFile(new File(path)).mkString)
  }
}
