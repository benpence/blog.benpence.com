package com.benpence.blog.server

import com.benpence.blog.model.Post
import com.benpence.blog.service._
import com.benpence.blog.store.PostStore
import com.twitter.util.{Await, Future}
import org.scalatest.WordSpec

class ApiServiceTest extends WordSpec {

  val testPost1 = Post(
    id = "abc",
    title = "How I Met Your String",
    createdMillis = 87987989,
    tags = Set("mother", "how"),
    content = "this is how I met her"
  )

  val testPost2 = Post(
    id = "def",
    title = "How I Met Your Father",
    createdMillis = 879879888,
    tags = Set("father", "how"),
    content = "this is how I met him"
  )

  val posts = Seq(testPost1, testPost2)

  val fullStore = new PostStore {
    def all = Future.value(posts)
    def getById(id: String) = Future.value(Some(testPost1))
    def query(q: String) = Future.value(Seq(testPost1))
  }

  val emptyStore = new PostStore {
    def all = Future.value(Seq.empty)
    def getById(id: String) = Future.value(None)
    def query(q: String) = Future.value(Seq.empty)
  }

  val failingStore = new PostStore {
    def all = Future.exception(new Exception("Failed"))
    def getById(id: String) = Future.exception(new Exception("Failed"))
    def query(q: String) = Future.exception(new Exception("Failed"))
  }


  "ApiService" should {
    val idRequest = PostIdRequest(id = testPost1.id)
    val queryRequest = PostQueryRequest(q = testPost1.content)

    "retrieve values when requests succeed" in {
      val apiService = new ApiService(fullStore)

      assert(Await.result(apiService.postAll) === Successful(posts))
      assert(Await.result(apiService.postId(idRequest)) === Successful(testPost1))
      assert(Await.result(apiService.postQuery(queryRequest)) === Successful(Seq(testPost1)))
    }

    "handle no values ok" in {
      val apiService = new ApiService(emptyStore)

      assert(Await.result(apiService.postAll) === Successful(Seq.empty))
      assert(Await.result(apiService.postId(idRequest)) === InvalidPostId(testPost1.id))
      assert(Await.result(apiService.postQuery(queryRequest)) === Successful(Seq.empty))
    }

    "fail when the store fails" in {
      val apiService = new ApiService(failingStore)

      assert(Await.result(apiService.postAll) === InternalError)
      assert(Await.result(apiService.postId(idRequest)) === InternalError)
      assert(Await.result(apiService.postQuery(queryRequest)) === InternalError)
    }
  }
}
