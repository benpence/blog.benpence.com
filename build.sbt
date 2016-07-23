name := "blog"
organization := "com.benpence"
version := "0.0.1-SNAPSHOT"
scalaVersion := "2.11.7"

lazy val versions = new {
  val finatra = "2.1.6"
  val finagle = "6.35.0"
  val mockito = "1.8.5"
  val scalaCheck = "1.12.2"
  val scalaTest = "2.2.4"
  val storehaus = "0.15.0-RC1"
  val slf4j = "1.7.12"
}

resolvers ++= Seq(
  Resolver.sonatypeRepo("releases")
)

libraryDependencies ++= Seq(
  "com.twitter.finatra" %% "finatra-http"       % versions.finatra,
  "com.twitter.finatra" %% "finatra-httpclient" % versions.finatra,
  "com.twitter"         %% "finagle-mysql"      % versions.finagle,
  "com.twitter"         %% "storehaus-core"     % versions.storehaus,
  "org.slf4j"           %  "slf4j-api"          % versions.slf4j,
  "org.slf4j"           %  "slf4j-simple"       % versions.slf4j,

  "org.mockito"         % "mockito-all"         % versions.mockito     % "test",
  "org.scalacheck"      %% "scalacheck"         % versions.scalaCheck  % "test",
  "org.scalatest"       %% "scalatest"          % versions.scalaTest   % "test"
)
