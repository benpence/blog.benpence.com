package com.benpence.blog.util

import com.twitter.util.Future
import scala.util.{Failure, Try, Success}

object PrimitiveEnrichments {
  implicit class RichOption[A](val option: Option[A]) extends AnyVal {
    def toTry(throwable: Throwable): Try[A] = option match {
      case Some(v) => Success(v)
      case _       => Failure(throwable)
    }
  }

  implicit class RichTry[A](val trie: Try[A]) extends AnyVal {
    def toFuture: Future[A] = {
      trie match {
        case Success(v) => Future.value(v)
        case Failure(t) => Future.exception(t)
      }
    }

    def mapThrow(transformThrowable: Throwable => Throwable): Try[A] = {
      trie match {
        case s @ Success(_) => s
        case Failure(t) => Failure(transformThrowable(t))
      }
    }
  }

  implicit class RichFuture[A](val future: Future[A]) extends AnyVal {
    def const[B](value: B): Future[B] = future.map { _ => value }
  }
}

object TryUtils {
  /*
   * Return successful list or first failure
   */
  def sequence[A](trys: Seq[Try[A]]): Try[Seq[A]] = {
    trys.foldLeft(Try(Seq.empty[A])){
      case (Success(acc), Success(v)) => Success(v +: acc)
      case (Success(_),   Failure(t)) => Failure(t)
      case (l,            _         ) => l
    }
  }
}
