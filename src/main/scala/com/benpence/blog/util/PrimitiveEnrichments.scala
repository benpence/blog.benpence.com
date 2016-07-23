package com.benpence.blog.util

import com.twitter.util.Future

object FutureEnrichments {
  implicit class RichFuture[A](val future: Future[A]) extends AnyVal {
    def const[B](value: B): Future[B] = future.map { _ => value }
  }
}
