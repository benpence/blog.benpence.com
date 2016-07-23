package com.benpence.blog.store

/*import com.twitter.util.{Future, Return, Throw}
import com.twitter.finagle.exp.mysql
import com.twitter.finagle.exp.mysql.Parameter._

case class Key(asInt: Int) extends AnyVal
case class NoteType(name: String, description: String)

sealed abstract class StoreException(msg: String) extends RuntimeException(msg)
case class MySqlResultException(msg: String)
  extends StoreException(msg)
case class MySqlStatementException(error: mysql.Error)
  extends StoreException("Error with MySQL syntax/configuration")
case class MySqlConnectionException(t: Throwable)
  extends StoreException("Error with MySQL connection")

trait NoteTypeStore {
  def getNoteTypes: Future[Seq[(Key, NoteType)]]
  def createNoteType(noteType: NoteType): Future[Key]
  def updateNoteType(key: Key, note: NoteType): Future[Unit]
  def deleteNoteType(key: Key): Future[Unit]
}

object MysqlNoteTypeStore {
  def raiseThrows[T](f: Future[mysql.Result])(func: PartialFunction[mysql.Result, Future[T]]): Future[T] = {
    f.liftToTry.flatMap {
      case Return(err: mysql.Error) => Future.exception(MySqlStatementException(err))
      case Return(r) if func.isDefinedAt(r) => func(r)
      case Throw(t: Throwable) => Future.exception(MySqlConnectionException(t))
    }
  }
}

trait MysqlNoteTypeStore extends NoteTypeStore {
  import MysqlNoteTypeStore._

  val client: mysql.Client
  val table: String

  val getStmt = client.prepare(
    s"""
      SELECT (
        `id`,
        `name`,
        `description`
      ) FROM $table;
    """)
    
  val createStmt = client.prepare(
    s"""
      INSERT INTO `$table` (
        `name`,
        `description`
      ) VALUES (
        @name,
        @description
      );

      SELECT LAST_INSERT_ID();
    """)

  val updateStmt = client.prepare(
    s"""
      UPDATE `$table`
      SET
        `name` = @name
        `description` = @description
      WHERE `id` = @id;
    """)

  val deleteStmt = client.prepare(
    s"""
      DELETE FROM `$table`
      WHERE `id` = @id;
    """)

  def getNoteTypes: Future[Seq[(Key, NoteType)]] = {
    raiseThrows(createStmt()){ case resultSet: mysql.ResultSet =>
      val transformedResultSet = resultSet.rows.map { row =>
        row.values match {
          case Seq(
            mysql.IntValue(key),
            mysql.StringValue(name),
            mysql.StringValue(description)
            ) => (Key(key), NoteType(name, description))
          case _ => throw MySqlResultException(s"Expeced row to be (id, name, descriptio). Got $row")
        }
      }

      Future.value(transformedResultSet)
    }
  }

  def createNoteType(noteType: NoteType): Future[Key] = {
    val creation = createStmt(noteType.name, noteType.description)

    raiseThrows(creation){ case resultSet: mysql.ResultSet =>
      resultSet.rows match {
        case Seq(row) => Future.value(Key(row.values(0).asInstanceOf[mysql.IntValue].i))
        case _ => Future.exception(MySqlResultException(s"Expected 1 ID. Got $resultSet"))
      }
    }
  }

  def updateNoteType(key: Key, noteType: NoteType): Future[Unit] = {
    val update = updateStmt(key.asInt, noteType.name, noteType.description) 
    raiseThrows(update){ case _: mysql.OK => Future.Unit }
  }

  def deleteNoteType(key: Key): Future[Unit] = {
    val deletion = deleteStmt(key.asInt) 
    raiseThrows(deletion){
      case _: mysql.OK => Future.Unit
    }.unit
  }
}*/
