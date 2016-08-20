package com.benpence.blog.util

import com.benpence.blog.util.PrimitiveEnrichments._
import com.twitter.scalding.Args
import java.io.File
import scala.util.Try

case class FailedValidationException(key: String, format: String, t: Throwable)
  extends RuntimeException(s"Expected argument --$key to be of '$format'", t)

object ArgsEnrichments {
  implicit class RichArgs(val args: Args) extends AnyVal {
    def validate[A](key: String, format: String)(validateF: String => A): A = {
      Try(validateF(args.required(key)))
        .mapThrow { t => FailedValidationException(key, format, t) }
        .get
    }

    def existingFile(key: String): File = {
      validate(key, "existing file"){ value =>
        val file = new File(value)
        require(file.exists, "File must exist")
        file
      }
    }
  }
}
