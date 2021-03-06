package com.cloudpartners

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapper
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBScanExpression
import com.amazonaws.services.dynamodbv2.model.*
import com.cloudpartners.local.LocalDynamoDB
import com.cloudpartners.model.Group
import com.cloudpartners.model.Participant
import com.cloudpartners.model.Session
import com.cloudpartners.model.UserInfo
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.KotlinModule
import spark.Filter
import spark.Request
import spark.Service
import java.io.File
import java.util.*
import spark.Spark.*
import java.net.URI

class Server {

}

fun isDev(): Boolean {
    return System.getProperty("ENVIRONMENT","local").equals("local")
}

fun frontendUrl(): String {
    return System.getProperty("FRONTEND_URL","http://localhost:64896/")
}

fun configFile(): String {
    return System.getProperty("CONFIG_PROPERTIES","config.properties")
}

class LocalDynamoDBHelper(private val client: AmazonDynamoDB) {
    private fun tableExists(name: String): Boolean {
        return try {
            client.describeTable(name)
            true
        } catch (e: ResourceNotFoundException) {
            false
        }
    }

    fun createOrUpdate(name: String, attributes: List<AttributeDefinition>, hashKey: String, rangeKey: String?) {
        val hashKeySchemaElement = KeySchemaElement(hashKey, KeyType.HASH)
        val rangeKeySchemaElement = if (rangeKey != null) KeySchemaElement(rangeKey, KeyType.RANGE) else null

        val keySchema : List<KeySchemaElement> =
                Arrays.asList(hashKeySchemaElement, rangeKeySchemaElement)
                        .filterNotNull()

        if (tableExists(name)) {
            1 // TODO: Recreate table if structure has changed.
        } else {
            client.createTable(
                    CreateTableRequest()
                            .withTableName(name)
                            .withAttributeDefinitions(attributes)
                            .withKeySchema(keySchema)
                            .withProvisionedThroughput(ProvisionedThroughput(2,2)))
        }
    }
}


fun main(args: Array<String>) {
    // Start a local db
    val db = LocalDynamoDB(File("scoutcamp.db"))
    db.start()
    val tableHelper = LocalDynamoDBHelper(db.client)
    tableHelper.createOrUpdate(
            "group",
            Arrays.asList(AttributeDefinition("id", "S")),
            "id",
            null)
    tableHelper.createOrUpdate(
            "participant",
            Arrays.asList(AttributeDefinition("id", "S")),
            "id",
            null)
    tableHelper.createOrUpdate(
            "session",
            Arrays.asList(AttributeDefinition("sessionId", "S")),
            "sessionId",
            null)

    println("Running")
    println("Configuration: ")
    println("  ENVIRONMENT="+System.getProperty("ENVIRONMENT"))
    println("  FRONTEND_URL="+System.getProperty("FRONTEND_URL"))
    println("  CONFIG_PROPERTIES="+System.getProperty("CONFIG_PROPERTIES"))
    val mapper = DynamoDBMapper(db.client)
    val jacksonObjectMapper = ObjectMapper().registerModule(KotlinModule())
    after(Filter({ req, res ->
        res.header("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,OPTIONS")
        res.header("Access-Control-Allow-Origin", req.headers("Origin"))
        res.header("Access-Control-Allow-Headers", "Content-Type,Authorization,X-Requested-With,Content-Length,Accept,Origin,")
        res.header("Access-Control-Allow-Credentials", "true")
    }))
    options("/*") { _,_ -> "ok"}
    path("/user") {
        get("/info") { req, res ->
            var info : UserInfo = UserInfo.development()
            if (isDev()) {
            } else {
                val session: Session? = session(req, mapper)
                if (session != null) {
                    val token = session.token
                    val claims = getJWTClaims(token)?.body
                    info = UserInfo(claims?.subject ?: "", claims?.get("name")?.toString()
                            ?: "", claims?.get("email")?.toString() ?: "")
                } else {
                    info = UserInfo.notLoggedIn()
                }
            }
            jacksonObjectMapper.writeValueAsString(info)
        }
    }
    path("/groups") {
        get("") { req, res ->
            jacksonObjectMapper.writeValueAsString(mapper.scan(Group::class.java, DynamoDBScanExpression()))
        }
        get("/:id") { req, res ->
            val id = req.params("id")
            val group = mapper.load(Group::class.java, id)
            jacksonObjectMapper.writeValueAsString(group)
        }
        post("/create", "application/json") { req, res ->
           val group = jacksonObjectMapper.readValue(req.body(), Group::class.java)
           mapper.save(group)
           "ok"
        }
        delete("/:id") { req, res ->
            val id = req.params("id")
            val group = mapper.load(Group::class.java, id)
            mapper.delete(group)
            "ok"
        }
    }
    path( "/participants") {
        get ( "") { req, res ->
            jacksonObjectMapper.writeValueAsString(mapper.scan(Participant::class.java, DynamoDBScanExpression()))
        }
        get("/:id") { req, res ->
            val id = req.params("id")
            val participant = mapper.load(Participant::class.java, id)
            jacksonObjectMapper.writeValueAsString(participant)
        }
        post("/create", "application/json") { req, res ->
            val participant = jacksonObjectMapper.readValue(req.body(), Participant::class.java)
            mapper.save(participant)
            "ok"
        }
        delete("/:id") { req, res ->
            val id = req.params("id")
            val participant = mapper.load(Participant::class.java, id)
            mapper.delete(participant)
            "ok"
        }
    }
    path("/isLoggedIn") {
        get("") { req, res ->
            var session: Session? = session(req, mapper)
            if (session == null) return@get "NO"

            val token = session.token

            if (isDev()) return@get "YES"
            if (isJWTValid(token)) "YES" else "NO"
        }
    }
    path("/authenticate") {
        get("") {req,res ->
            val code = req.queryParams("code")
            println("Received code: $code")
            val token = if (isDev()) code else codeToToken(code)
            println("Code resolved to token $token")
            val sessionId = UUID.randomUUID().toString()
            res.cookie("auth", sessionId)
            mapper.save(Session(sessionId, token))
            res.redirect(frontendUrl())
        }
    }
    path("/simulateCognito") {
        get("") { req,res ->
            res.redirect("authenticate?code=1234")
        }
    }

}

private fun session(req: Request, mapper: DynamoDBMapper): Session? {
    val a: String? = req.cookie("auth")
    var session: Session? = null
    if (a != null) {
        session = mapper.load(Session::class.java, a)
    }
    val token = session?.token
    println("loaded token from cookie: $token")
    return session
}