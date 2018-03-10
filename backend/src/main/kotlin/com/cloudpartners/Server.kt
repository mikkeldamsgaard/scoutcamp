package com.cloudpartners

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapper
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBScanExpression
import com.amazonaws.services.dynamodbv2.model.*
import com.cloudpartners.local.LocalDynamoDB
import com.cloudpartners.model.Group
import com.cloudpartners.model.Participant
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.KotlinModule
import spark.Filter
import java.io.File
import java.util.*
import spark.Spark.*
class Server {

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
            // TODO: Recreate table if structure has changed.
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

    print("Running")
    val mapper = DynamoDBMapper(db.client)
    val jacksonObjectMapper = ObjectMapper().registerModule(KotlinModule())
    after(Filter({ req, res ->
        res.header("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,OPTIONS")
        res.header("Access-Control-Allow-Origin", "*")
        res.header("Access-Control-Allow-Headers", "Content-Type,Authorization,X-Requested-With,Content-Length,Accept,Origin,")
        res.header("Access-Control-Allow-Credentials", "true")
    }))
    options("/*") { _,_ -> "ok"}
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
}