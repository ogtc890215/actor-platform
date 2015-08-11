package im.actor.server.peer

import akka.pattern.ask
import akka.util.Timeout
import im.actor.api.rpc.messaging.{ Message ⇒ ApiMessage }
import im.actor.server.sequence.SeqStateDate

import scala.concurrent.{ ExecutionContext, Future }

object GroupPeerOperations {
  import GroupPeerCommands._

  def sendMessage(groupId: Int, senderUserId: Int, senderAuthId: Long, randomId: Long, message: ApiMessage, isFat: Boolean = false)(
    implicit
    region:  GroupPeerRegion,
    timeout: Timeout,
    ec:      ExecutionContext
  ): Future[SeqStateDate] =
    (region.ref ? SendMessage(groupId, senderUserId, senderAuthId, randomId, message, isFat)).mapTo[SeqStateDate]

  def messageReceived(groupId: Int, receiverUserId: Int, receiverAuthId: Long, date: Long)(
    implicit
    timeout: Timeout,
    region:  GroupPeerRegion,
    ec:      ExecutionContext
  ): Future[Unit] = {
    (region.ref ? MessageReceived(groupId, receiverUserId, receiverAuthId, date)).mapTo[MessageReceivedAck] map (_ ⇒ ())
  }

  def messageRead(groupId: Int, readerUserId: Int, readerAuthId: Long, date: Long)(
    implicit
    timeout: Timeout,
    region:  GroupPeerRegion,
    ec:      ExecutionContext
  ): Future[Unit] = {
    (region.ref ? MessageRead(groupId, readerUserId, readerAuthId, date)).mapTo[MessageReadAck] map (_ ⇒ ())
  }

}