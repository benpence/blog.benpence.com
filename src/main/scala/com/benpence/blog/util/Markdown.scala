package com.benpence.blog.util

import com.tristanhunt.knockoff._
import scala.util.Try


object Markdown {
  def parse(input: String): Try[Seq[Component]] = {
    Try {
      val blocks = DefaultDiscounter.knockoff(input)
      blocks.map(blockToComponent)
    }
  }

  case class Component(
    component: String,
    children: Seq[Component] = Seq.empty,
    attributes: Seq[(String, String)] = Seq.empty
  )

  def blockToComponent(block: Block): Component = {
    block match {
      case Paragraph(spans, _) =>
        Component("p", spans.map(spanToComponent))
      case Header(level, spans, _) =>
        Component(s"h$level", spans.map(spanToComponent))
      case LinkDefinition(id, url, title, _) =>
        val title_ = title.getOrElse("")
        Component("link", Seq.empty, Seq("id" -> id, "href" -> url, "alt" -> title_))
      case Blockquote(children, _) =>
        Component("blockquote", children.map(blockToComponent))
      case CodeBlock(text, _) =>
        Component("pre", Seq(spanToComponent(text)))
      case HorizontalRule(_) =>
        Component("hr")
      case OrderedItem(children, _) =>
        Component("li", children.map(blockToComponent))
      case UnorderedItem(children, _) =>
        Component("li", children.map(blockToComponent))
      case HTMLBlock(html, _) =>
        Component("html", Seq.empty, Seq("content" -> html))
      case OrderedList(items) =>
        Component("ol", items.map(blockToComponent))
      case UnorderedList(items) =>
        Component("ul", items.map(blockToComponent))
    }
  }

  def spanToComponent(span: Span): Component = {
    span match {
      case Text(content) =>
        Component("text", Seq.empty, Seq("content" -> content))
      case HTMLSpan(html) =>
        Component("html", Seq.empty, Seq("content" -> html))
      case CodeSpan(content) =>
        Component("code", Seq.empty, Seq("content" -> content))
      case Strong(children) =>
        Component("strong", children.map(spanToComponent))
      case Emphasis(children) =>
        Component("emphasis", children.map(spanToComponent))
      case Link(children, url, title) =>
        val title_ = title.getOrElse("")
        Component("a", children.map(spanToComponent), Seq("href" -> url, "alt" -> title_))
      case IndirectLink(children, definition) =>
        val link = blockToComponent(definition)
        val componentChildren = children.map(spanToComponent)

        link.copy(children = link.children ++ componentChildren)
      case ImageLink(children, url, title) =>
        val title_ = title.getOrElse("")

        Component("img", children.map(spanToComponent), Seq("src" -> url, "title" -> title_))
      case IndirectImageLink(children, LinkDefinition(id, url, title, _)) =>
        val title_ = title.getOrElse("")

        Component("img", children.map(spanToComponent), Seq("src" -> url, "title" -> title_))
    }
  }
}
