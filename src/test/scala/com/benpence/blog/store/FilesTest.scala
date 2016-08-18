package com.benpence.blog.store

import com.benpence.blog.model.{User, UserId, Post, PostId}
import com.benpence.blog.util.{UriLoader, Html}
import com.benpence.blog.util.PrimitiveEnrichments._
import java.io.FileNotFoundException
import org.scalacheck.{Arbitrary, Gen, Prop}
import org.scalacheck.Arbitrary._
import org.scalatest.WordSpec
import org.scalatest.prop.GeneratorDrivenPropertyChecks
import scala.util.Try

case class UsersTest(users: Seq[User])
case class PostsTest(postTests: Seq[PostTest])
case class PostTest(path: String, post: Post)

class FilesTest extends WordSpec with GeneratorDrivenPropertyChecks {
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
      val yaml =
        """|- id: 0
           |  name: Ben Space
           |  email: benspace@gmail.com
           |  passwordHash: Blah88
           |  isAdmin: true
           |  createdMillis: 27
           |- id: 1
           |  name: Space Ben
           |  email: spaceben@gmail.com
           |  passwordHash: Bluh88
           |  isAdmin: false
           |  createdMillis: 28""".stripMargin

      val expected = Try(Seq(
        User(
          UserId(0),
          "Ben Space",
          "benspace@gmail.com",
          "Blah88",
          true,
          27),
        User(
          UserId(1),
          "Space Ben",
          "spaceben@gmail.com",
          "Bluh88",
          false,
          28)
      ))

      assert(Users.fromYaml(yaml) === expected)

      forAll(arbitrary[UsersTest]) { case UsersTest(users) =>
        val blocks = users.map { user =>
          val User(UserId(id), name, email, pw, isAdmin, createdMillis) = user

          s"""|- id: $id
              |  name: $name
              |  email: $email
              |  passwordHash: $pw
              |  isAdmin: $isAdmin
              |  createdMillis: $createdMillis""".stripMargin
        }

        val yaml = blocks.mkString("\n")

        assert(Users.fromYaml(yaml) === Try(users))
      }
    }
  }

  "Posts" should {
    "successfully parse Posts from YAML and load their contents" in {
      val yaml = """|- id: 0
                    |  author: 1
                    |  title: The Title
                    |  createdMillis: 27
                    |  tags:
                    |    - beef
                    |    - pools
                    |  content:
                    |    uri: memory://first
                    |    markupLanguage: html
                    |- id: 1
                    |  author: 2
                    |  title: The Title 2
                    |  createdMillis: 28
                    |  tags: []
                    |  content:
                    |    uri: memory://second
                    |    markupLanguage: html""".stripMargin

      val loaders = Map("memory" -> MemoryLoader(Map(
        "first" -> "fist",
        "second" -> "secnd"
      )))

      val languages = Map("html" -> Html)

      val expected = Try(Seq(
        Post(
          PostId(0),
          UserId(1),
          "The Title",
          27,
          Set("beef", "pools"),
          "fist"),
        Post(
          PostId(1),
          UserId(2),
          "The Title 2",
          28,
          Set(),
          "secnd")
      ))

      assert(Posts.fromYaml(yaml)(loaders, languages) === expected)


      forAll(arbitrary[PostsTest]) { case PostsTest(postTests) =>
        val blocksAndFileEntries = postTests.map { case PostTest(path, post) =>
          val Post(PostId(id), UserId(author), title, createdMillis, tags, content) = post

          val tagBlock =
            if (tags.isEmpty) " []"
            else tags.map("\n    - " + _).mkString

          val block =
            s"""|- id: $id
                |  author: $author
                |  title: $title
                |  createdMillis: $createdMillis
                |  tags:$tagBlock
                |  content:
                |    uri: memory://$path
                |    markupLanguage: html""".stripMargin

          (block, (path, content))
        }

        val yaml = blocksAndFileEntries.map(_._1).mkString("\n")
        val pathsToContents = blocksAndFileEntries.map(_._2).toMap
        val loaders = Map("memory" -> MemoryLoader(pathsToContents))
        val languages = Map("html" -> Html)

        assert(Posts.fromYaml(yaml)(loaders, languages) === Try(postTests.map(_.post)))
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
    title <- Gen.identifier
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
