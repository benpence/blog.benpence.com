package com.benpence.blog.service

import com.benpence.blog.model.{ApiUser, Cookie, Login, User, UserId}
import com.benpence.blog.store.{LoginStore, UserQuery, UserStore}
import com.benpence.blog.util.Clock
import com.benpence.blog.util.FutureEnrichments._
import com.twitter.util.Future

sealed trait LoginFailure
case object NoSuchUser extends LoginFailure
case object WrongPassword extends LoginFailure

object LoginService {
  def projectToApiUser(user: User): ApiUser = ApiUser(user.id, user.name)
}

class LoginService (
  val userStore: UserStore,
  val loginStore: LoginStore,
  val clock: Clock,
  val makeCookie: () => Cookie,
  val cookieGoodForMillis: Option[Long]
) {

  import LoginService._

  def login(
    email: String,
    passwordHash: String
  ): Future[Either[LoginFailure, Cookie]] = {
    val emailQuery = UserQuery.ByEmail(email)
    userStore.queryable.get(emailQuery).flatMap {
      case Some(Seq(user)) if user.passwordHash == passwordHash => 
        // Add login to session table
        val login = Login(makeCookie(), user.id, clock.currentTimeMillis())
        loginStore
          .put((login.cookie, Some(login)))
          .const(Right(login.cookie))

      case Some(_) => Future.value(Left(WrongPassword))
      case None => Future.value(Left(NoSuchUser))
    }
  }

  def lookup(cookie: Cookie): Future[Option[ApiUser]] = {
    loginStore
      .get(cookie)
      .flatMap {
        case Some(Login(_, userId, timeLoggedInMillis)) if !isExpired(timeLoggedInMillis) =>
          userStore.get(userId).map(_.map(projectToApiUser))
        // Remove expired login
        case Some(_) => logout(cookie).const(None)
        case _ => Future.value(None)
      }
  }

  def logout(cookie: Cookie): Future[Unit] = loginStore.put((cookie, None)).unit

  private def isExpired(timeLoggedInMillis: Long) = cookieGoodForMillis.exists { duration =>
    (timeLoggedInMillis + duration) < clock.currentTimeMillis()
  }
}
