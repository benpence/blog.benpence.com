package com.benpence.blog.util

import com.benpence.blog.util.ArgsEnrichments._
import java.nio.file.Files
import java.io.File
import org.scalatest.WordSpec
import com.twitter.scalding.Args
import scala.util.{Failure, Try, Success}

class ArgsEnrichmentsTest extends WordSpec {
  "RichArgs" should {

    "#validate" in {
      val throwable = new RuntimeException("zzz")
      val args = Args("-test 1234 --best aaaa")
      assert(args.validate("test", "integer")(_.toLong) === 1234L)

      val e = intercept[FailedValidationException]{
        args.validate("best", "integer"){ _ => throw throwable }
      }
      assert(e === FailedValidationException("best", "integer", throwable))
    }

    "#existingFile" in {
      val readableFile = createTempFile()
      val path = readableFile.getAbsolutePath
      val args = Args(s"--input $path")

      assert(args.existingFile("input").getAbsolutePath === path)

      readableFile.delete()
      intercept[Throwable]{
        args.existingFile("input")
      }
    }

    def createTempFile(): File = {
      val file = Files.createTempFile("prefix", "suffix").toFile
      file.deleteOnExit()
      file
    }
  }
}
