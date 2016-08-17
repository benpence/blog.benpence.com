package com.benpence.blog.store

import com.benpence.blog.model.{User, UserId, Post, PostId}
import com.benpence.blog.util.{UriLoader, Html}
import com.benpence.blog.util.PrimitiveEnrichments._
import java.io.FileNotFoundException
import org.scalacheck.{Arbitrary, Gen, Prop}
import org.scalacheck.Arbitrary._
import org.scalatest.WordSpec
import org.scalatest.prop.Checkers

case class UsersTest(users: Seq[User])
case class PostsTest(postTests: Seq[PostTest])
case class PostTest(path: String, post: Post)

class FilesTest extends WordSpec with Checkers {
  import FilesTest._

  implicit val arbUsersTest: Arbitrary[UsersTest] = Arbitrary(Gen
    .nonEmptyListOf(arbitrary[User])
    .map(UsersTest(_)))

  implicit val arbPostTest: Arbitrary[PostTest] = Arbitrary(for {
    paths <- Gen.nonEmptyListOf(Gen.identifier)
    post <- arbitrary[Post]
  } yield PostTest(paths.mkString("/"), post))

  implicit val arbPostsTest: Arbitrary[PostsTest] = Arbitrary(Gen
    .nonEmptyListOf(arbitrary[PostTest])
    .map(PostsTest(_)))

  "Users" should {
    "successfully parse Users from YAML" in {
      check[UsersTest, Prop] { case UsersTest(users) =>
        val blocks = users.map { user =>
          val User(UserId(id), name, email, pw, isAdmin, createdMillis) = user

          s"""|
            |- id: $id\n"
            |  name: $name\n
            |  email: $email\n
            |  passwordHash: $pw\n
            |  isAdmin: $isAdmin\n
            |  createdMillis $createdMillis
            |""".stripMargin
        }

        val yaml = blocks.mkString("\n")

        Users.fromYaml(yaml) === users
      }
    }
  }

  "Posts" should {
    "successfully parse Posts from YAML and load their contents" in {
      check[PostsTest, Prop] { case PostsTest(postTests) =>
        val blocksAndFileEntries = postTests.map { case PostTest(path, post) =>
          val Post(PostId(id), UserId(author), title, createdMillis, tags, content) = post

          val tagBlock = tags.map("    - " + _).mkString("\n")

          val block = s"""|
            |- id: $id\n
            |  author: $author\n
            |  title: $title\n
            |  createdMillis: $createdMillis\n
            |  tags:\n$tagBlock\n
            |  content:\n
            |  uri: memory://$path\n
            |  markupLanguage: html
            |""".stripMargin

          (block, (path, content))
        }

        val yaml = blocksAndFileEntries.map(_._1).mkString("\n")

        val pathsToContents = blocksAndFileEntries.map(_._2).toMap
        val loaders = Map("memory" -> MemoryLoader(pathsToContents))
        val languages = Map("html" -> Html)

        Posts.fromYaml(yaml)(loaders, languages) === postTests.map(_.post)
      }
    }
  }
}

object FilesTest {
  val emailGen = for {
    user <- Gen.identifier
    domains <- Gen.nonEmptyListOf(Gen.identifier)
  } yield {
    val domain = domains.mkString(".")
    s"$user@$domain"
  }

  implicit val arbUserId: Arbitrary[UserId] = Arbitrary(arbitrary[Long].map(UserId(_)))

  implicit val arbUser: Arbitrary[User] = Arbitrary(for {
    id <- arbitrary[UserId]
    names <- Gen.nonEmptyListOf(Gen.identifier)
    email <- emailGen
    passwordHash <- Gen.identifier
    isAdmin <- arbitrary[Boolean]
    createdMillis <- Gen.posNum[Long]
  } yield User(id, names.mkString(" "), email, passwordHash, isAdmin, createdMillis))

  implicit val arbPostId: Arbitrary[PostId] = Arbitrary(arbitrary[Long].map(PostId(_)))

  implicit val arbPost: Arbitrary[Post] = Arbitrary(for {
    id <- arbitrary[PostId]
    author <- arbitrary[UserId]
    title <- arbitrary[String]
    createdMillis <- Gen.posNum[Long]
    tags <- Gen.containerOf[Set, String](Gen.identifier)
    content <- arbitrary[String]
  } yield Post(id, author, title, createdMillis, tags, content))
}

case class MemoryLoader(pathsToContents: Map[String, String]) extends UriLoader {
  override val name = "memory"
  override def load(path: String) = pathsToContents
    .get(path)
    .toTry(new FileNotFoundException(s"$path (No such file or directory)"))
}
