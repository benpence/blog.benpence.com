package com.benpence.blog.util

import com.benpence.blog.util.PrimitiveEnrichments._
import org.scalatest.WordSpec
import scala.util.{Failure, Try, Success}
import com.twitter.util.{Await, Future}

class PrimitivesTest extends WordSpec {
  val throwable = new RuntimeException("bee")
  val success = Success(())
  val failure = Failure(throwable)

  "PrimitiveEnrichments" should {

    "RichOption#toTry" in {
      assert(Some(()).toTry(throwable) === success)
      assert(None.toTry(throwable)     === failure)
    }

    "RichTry#toFuture" in {
      assert(Await.result(success.toFuture) === ())

      val e = intercept[RuntimeException](Await.result(failure.toFuture))
      assert(e === throwable)
    }

    "RichTry#mapThrow" in {
      val otherThrowable = new RuntimeException("boo")
      val mappedFailure = failure.mapThrow { e =>
        assert(e === throwable)
        otherThrowable
      }

      assert(mappedFailure === Failure(otherThrowable))
    }

    "RichFuture#const" in {
      val otherValue = 5

      val future = Future.Unit.const(otherValue)
      assert(Await.result(future) === otherValue)
    }
  }

  "TryUtils" should {
    "sequence" in {
      val failedSequence = Seq(success, success, failure)
      assert(TryUtils.sequence(failedSequence) === failure)

      val successSequence = Seq(success, success, Success(1))
      assert(TryUtils.sequence(successSequence) === Success(Seq((), (), 1)))
    }
  }
}
