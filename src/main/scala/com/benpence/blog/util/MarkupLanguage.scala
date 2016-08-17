package com.benpence.blog.util

import org.pegdown.PegDownProcessor
import scala.util.Try

object MarkupLanguage {
  def defaults = Set(
    MarkdownFormat
  )
}

sealed trait MarkupLanguage {
  def name: String
  def toHtml(content: String): Try[String]
}

case object Html extends MarkupLanguage {
  override val name = "html"
  override def toHtml(content: String) = Try(content)
}

case object MarkdownFormat extends MarkupLanguage {
  private val processor = new PegDownProcessor

  override val name = "markdown"
  override def toHtml(markdown: String) = Try {
    processor.synchronized {
      processor.markdownToHtml(markdown)
    }
  }
}
