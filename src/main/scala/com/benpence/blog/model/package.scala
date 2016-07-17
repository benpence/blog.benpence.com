package com.benpence.blog.model

case class Post(
  id: String,
  title: String,
  createdMillis: Long,
  tags: Set[String],
  content: String
)
