package im.actor.server.http

import java.nio.file.Paths

import scala.concurrent.forkjoin.ThreadLocalRandom

import org.scalatest.Inside._
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.{ HttpMethods, HttpRequest, StatusCodes }
import akka.util.ByteString
import com.amazonaws.auth.EnvironmentVariableCredentialsProvider
import com.amazonaws.services.s3.transfer.TransferManager
import com.github.dwhjames.awswrap.s3.AmazonS3ScalaClient
import play.api.libs.json._

import im.actor.api.rpc.ClientData
import im.actor.server.api.http.json.{ JsonImplicits, AvatarUrls }
import im.actor.server.api.http.{ HttpApiConfig, HttpApiFrontend }
import im.actor.server.api.rpc.service.groups.{ GroupInviteConfig, GroupsServiceImpl }
import im.actor.server.api.rpc.service.{ GroupsServiceHelpers, messaging }
import im.actor.server.peermanagers.{ GroupPeerManager, PrivatePeerManager }
import im.actor.server.presences.{ GroupPresenceManager, PresenceManager }
import im.actor.server.social.SocialManager
import im.actor.server.util.{ ImageUtils, FileUtils, ACLUtils }
import im.actor.server.{ BaseAppSuite, models, persist }

class HttpApiFrontendSpec extends BaseAppSuite with GroupsServiceHelpers {
  behavior of "HttpApiFrontend"

  it should "respond with OK to webhooks text message" in t.textMessage()

  //  it should "respond with OK to webhooks document message" in t.documentMessage()//TODO: not implemented yet

  //  it should "respond with OK to webhooks image message" in t.imageMessage()//TODO: not implemented yet

  it should "respond with JSON message to group invite info with correct invite token" in t.groupInvitesOk()

  it should "respond with JSON message with avatar full links to group invite info with correct invite token" in t.groupInvitesAvatars1()

  it should "respond with JSON message with avatar partial links to group invite info with correct invite token" in t.groupInvitesAvatars2()

  it should "respond with Not Acceptable to group invite info with invalid invite token" in t.groupInvitesInvalid()

  it should "respond BadRequest" in t.malformedMessage()

  implicit val sessionRegion = buildSessionRegionProxy()
  implicit val seqUpdManagerRegion = buildSeqUpdManagerRegion()
  implicit val socialManagerRegion = SocialManager.startRegion()
  implicit val presenceManagerRegion = PresenceManager.startRegion()
  implicit val groupPresenceManagerRegion = GroupPresenceManager.startRegion()
  implicit val privatePeerManagerRegion = PrivatePeerManager.startRegion()
  implicit val groupPeerManagerRegion = GroupPeerManager.startRegion()

  val bucketName = "actor-uploads-test"
  val awsCredentials = new EnvironmentVariableCredentialsProvider()
  implicit val transferManager = new TransferManager(awsCredentials)
  implicit val client = new AmazonS3ScalaClient(awsCredentials)
  val groupInviteConfig = GroupInviteConfig("http://actor.im")

  implicit val service = messaging.MessagingServiceImpl(mediator)
  implicit val authService = buildAuthService()
  implicit val groupsService = new GroupsServiceImpl("", groupInviteConfig)

  implicit val ec = system.dispatcher

  object t {
    val (user1, authId1, _) = createUser()
    val (user2, authId2, _) = createUser()
    val sessionId = createSessionId()
    implicit val clientData = ClientData(authId1, sessionId, Some(user1.id))

    val groupName = "Test group"
    val groupOutPeer = createGroup(groupName, Set(user2.id)).groupPeer

    val config = HttpApiConfig("https://api.actor.im", "localhost", 9000)
    HttpApiFrontend.start(config, "actor-uploads-test")

    val http = Http()

    def textMessage() = {
      whenReady(db.run(persist.GroupBot.findByGroup(groupOutPeer.groupId))) { bot ⇒
        bot shouldBe defined
        val botToken = bot.get.token
        val request = HttpRequest(
          method = HttpMethods.POST,
          uri = s"http://${config.interface}:${config.port}/v1/webhooks/$botToken",
          entity = """{"text":"Good morning everyone!"}"""
        )
        whenReady(http.singleRequest(request)) { resp ⇒
          resp.status shouldEqual StatusCodes.OK
        }
      }
    }

    def documentMessage() = {
      whenReady(db.run(persist.GroupBot.findByGroup(groupOutPeer.groupId))) { bot ⇒
        bot shouldBe defined
        val botToken = bot.get.token
        val request = HttpRequest(
          method = HttpMethods.POST,
          uri = s"http://${config.interface}:${config.port}/v1/webhooks/$botToken",
          entity = """{"document_url":"http://www.scala-lang.org/docu/files/ScalaReference.pdf"}"""
        )
        whenReady(http.singleRequest(request)) { resp ⇒
          resp.status shouldEqual StatusCodes.OK
        }
      }
    }

    def imageMessage() = {
      whenReady(db.run(persist.GroupBot.findByGroup(groupOutPeer.groupId))) { bot ⇒
        bot shouldBe defined
        val botToken = bot.get.token
        val request = HttpRequest(
          method = HttpMethods.POST,
          uri = s"http://${config.interface}:${config.port}/v1/webhooks/$botToken",
          entity = """{"image_url":"http://www.scala-lang.org/resources/img/smooth-spiral.png"}"""
        )
        whenReady(http.singleRequest(request)) { resp ⇒
          resp.status shouldEqual StatusCodes.OK
        }
      }
    }

    def malformedMessage() = {
      whenReady(db.run(persist.GroupBot.findByGroup(groupOutPeer.groupId))) { bot ⇒
        bot shouldBe defined
        val botToken = bot.get.token
        val request = HttpRequest(
          method = HttpMethods.POST,
          uri = s"http://${config.interface}:${config.port}/v1/webhooks/$botToken",
          entity = """{"WRONG":"Should not be parsed"}"""
        )
        whenReady(http.singleRequest(request)) { resp ⇒
          resp.status shouldEqual StatusCodes.BadRequest
        }
      }
    }

    def groupInvitesOk() = {
      val token = ACLUtils.accessToken(ThreadLocalRandom.current())
      val inviteToken = models.GroupInviteToken(groupOutPeer.groupId, user1.id, token)
      whenReady(db.run(persist.GroupInviteToken.create(inviteToken))) { _ ⇒
        val request = HttpRequest(
          method = HttpMethods.GET,
          uri = s"http://${config.interface}:${config.port}/v1/groups/invites/$token"
        )
        val resp = whenReady(http.singleRequest(request))(identity)
        resp.status shouldEqual StatusCodes.OK
        whenReady(resp.entity.dataBytes.runFold(ByteString.empty)(_ ++ _).map(_.decodeString("utf-8"))) { body ⇒
          val response = Json.parse(body)
          (response \ "groupTitle").as[String] shouldEqual groupName
          (response \ "inviterName").as[String] shouldEqual user1.name
        }
      }
    }

    def groupInvitesAvatars1() = {
      val avatarFile = Paths.get(getClass.getResource("/valid-avatar.jpg").toURI).toFile
      val fileLocation = whenReady(db.run(FileUtils.uploadFile(bucketName, "avatar", avatarFile)))(identity)
      whenReady(db.run(ImageUtils.scaleAvatar(fileLocation.fileId, ThreadLocalRandom.current(), bucketName))) { result ⇒
        result should matchPattern { case Right(_) ⇒ }
        val avatar = ImageUtils.getAvatarData(models.AvatarData.OfGroup, groupOutPeer.groupId, result.right.toOption.get)
        whenReady(db.run(persist.AvatarData.createOrUpdate(avatar)))(_ ⇒ ())
      }

      val token = ACLUtils.accessToken(ThreadLocalRandom.current())
      val inviteToken = models.GroupInviteToken(groupOutPeer.groupId, user1.id, token)
      whenReady(db.run(persist.GroupInviteToken.create(inviteToken))) { _ ⇒
        val request = HttpRequest(
          method = HttpMethods.GET,
          uri = s"http://${config.interface}:${config.port}/v1/groups/invites/$token"
        )
        val resp = whenReady(http.singleRequest(request))(identity)
        resp.status shouldEqual StatusCodes.OK
        whenReady(resp.entity.dataBytes.runFold(ByteString.empty)(_ ++ _).map(_.decodeString("utf-8"))) { body ⇒
          import JsonImplicits.avatarUrlsFormat

          val response = Json.parse(body)
          (response \ "groupTitle").as[String] shouldEqual groupName
          (response \ "inviterName").as[String] shouldEqual user1.name
          val avatarUrls = (response \ "groupAvatars").as[AvatarUrls]
          inside(avatarUrls) {
            case AvatarUrls(Some(small), Some(large), Some(full)) ⇒
              List(small, large, full) foreach (_ should startWith(s"https://$bucketName.s3.amazonaws.com"))
          }
          (response \ "inviterAvatars").as[AvatarUrls] should matchPattern {
            case AvatarUrls(None, None, None) ⇒
          }
        }
      }
    }

    def groupInvitesAvatars2() = {
      val avatarFile = Paths.get(getClass.getResource("/valid-avatar.jpg").toURI).toFile
      val fileLocation = whenReady(db.run(FileUtils.uploadFile(bucketName, "avatar", avatarFile)))(identity)
      whenReady(db.run(ImageUtils.scaleAvatar(fileLocation.fileId, ThreadLocalRandom.current(), bucketName))) { result ⇒
        result should matchPattern { case Right(_) ⇒ }
        val avatar =
          ImageUtils.getAvatarData(models.AvatarData.OfGroup, groupOutPeer.groupId, result.right.toOption.get)
            .copy(smallAvatarFileId = None, smallAvatarFileHash = None, smallAvatarFileSize = None)
        whenReady(db.run(persist.AvatarData.createOrUpdate(avatar)))(_ ⇒ ())
      }

      val token = ACLUtils.accessToken(ThreadLocalRandom.current())
      val inviteToken = models.GroupInviteToken(groupOutPeer.groupId, user1.id, token)
      whenReady(db.run(persist.GroupInviteToken.create(inviteToken))) { _ ⇒
        val request = HttpRequest(
          method = HttpMethods.GET,
          uri = s"http://${config.interface}:${config.port}/v1/groups/invites/$token"
        )
        val resp = whenReady(http.singleRequest(request))(identity)
        resp.status shouldEqual StatusCodes.OK
        whenReady(resp.entity.dataBytes.runFold(ByteString.empty)(_ ++ _).map(_.decodeString("utf-8"))) { body ⇒
          import JsonImplicits.avatarUrlsFormat

          val response = Json.parse(body)
          (response \ "groupTitle").as[String] shouldEqual groupName
          (response \ "inviterName").as[String] shouldEqual user1.name
          val avatarUrls = (response \ "groupAvatars").as[AvatarUrls]
          inside(avatarUrls) {
            case AvatarUrls(None, Some(large), Some(full)) ⇒
              List(large, full) foreach (_ should startWith(s"https://$bucketName.s3.amazonaws.com"))
          }
          (response \ "inviterAvatars").as[AvatarUrls] should matchPattern {
            case AvatarUrls(None, None, None) ⇒
          }
        }
      }
    }

    def groupInvitesInvalid() = {
      val invalidToken = "Dkajsdljasdlkjaskdj329u90u32jdjlksRandom_stuff"
      val request = HttpRequest(
        method = HttpMethods.GET,
        uri = s"http://${config.interface}:${config.port}/v1/groups/invites/$invalidToken"
      )
      val resp = whenReady(http.singleRequest(request))(identity)
      resp.status shouldEqual StatusCodes.NotAcceptable
    }

  }

}