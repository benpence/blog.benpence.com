package com.benpence.blog.server

import com.twitter.util.Future
import com.twitter.finagle.http.Request
import com.twitter.finatra.http.Controller

class LoginController extends Controller {
  get("/login") { request: Request =>
    response.ok.file("index.html")
  }
}

// https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)_Prevention_Cheat_Sheet
case class Csrf(asString: String)
trait SecurityAgent {
  def isValidRequest(
    originHeader: Option[String],
    referrerHeader: Option[String],
    csrf: Csrf
  ): Future[Boolean]

  def generateCsrf: Future[Csrf]
}

/*
   - Give initial token(s) in HTML or through JS API call (is there risk if CSRF not paired with cookie? Consider pair with cookie on initial / load?)
   - API makes POST request through JS with CSRF. Response has new CSRF (do we need to give more than 1 CSRF per full HTML load?)
   - Login service verifies that CSRF is valid (and matches cookie?). Makes action. Drops CSRF. Retutrns new CSRF in JSON
   - Front-end regenerates submit function with new CSRF

   Create functional wrapper for controllers
     def withCsrf[A, B](func: (A, Client) => B)(a: A): Future[Either[BadToken, B]]]
*/


/*
case class ClientId(asLong: Long) extends AnyVal
case class EventId(asLong: Long) extends AnyVal
sealed trait ClientEvent {
  def clientId: ClientId
}
trait ClientService {
  def addEvent(siteVersion: String, clientId: ClientId, event: ClientEvent): Future[Unit]
}
*/
