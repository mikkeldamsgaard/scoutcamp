package com.cloudpartners.model

import com.amazonaws.services.dynamodbv2.datamodeling.*
import java.util.*

@DynamoDBTable(tableName="group")
data class Group(
        @DynamoDBHashKey var id: String = "",
        var name: String = "",
        var contactName: String? = null,
        var contactEmail: String? = null,
        var contactAddress: String? = null,
        var contactZip: String? = null,
        var contactCity: String? = null,
        var contactCountry: String? = null,
        var accountingName: String? = null,
        var accountingAccountNo: String? = null,
        var accountingPhone: String? = null,
        var accountingEmail: String? = null)

@DynamoDBTable(tableName="activity")
data class Activity(
        @DynamoDBHashKey var id: String = "",
        var name: String = "",
        var description: String = "",
        var ageGroup: String = ""
)

@DynamoDBTable(tableName="activitySlot")
data class ActivitySlot(
        @DynamoDBHashKey var id: String = "",
        @DynamoDBRangeKey var activityId: String = "",
        var from: Date? =null,
        var to: Date? = null
)

@DynamoDBTable(tableName="participant")
data class Participant(
        @DynamoDBHashKey var id: String = "",
        var name: String = "",
        var birthday: String? = null,
        var vegan: Boolean = false,
        var vegetarian: Boolean = false,
        var muslim: Boolean = false,
        var kosher: Boolean = false,
        var glutenAllergies: Boolean = false,
        var extraAllergies: String? = null,
        var needsElectricity: Boolean = false,
        @DynamoDBTyped(DynamoDBMapperFieldModel.DynamoDBAttributeType.L)
        var participations: List<Participation> = ArrayList()
)

@DynamoDBTyped(DynamoDBMapperFieldModel.DynamoDBAttributeType.M)
data class Participation(
        var groupId:  String? = "",
        var type: String = "Group",
        var date: String? = null,
        var morning: Boolean = true,
        var midday: Boolean = true,
        var evening: Boolean = true,
        var campType: String? = null,
        var needElectricity: Boolean = true
)

@DynamoDBTable(tableName="GroupParticipation")
data class GroupParticipation(
        @DynamoDBHashKey var id: String = "",
        var participantId: String = "",
        var groupId:  String = "",
        var date: Date? = null,
        var isMorning: Boolean = true,
        var isMidday: Boolean = true,
        var isEvening: Boolean = true
)

@DynamoDBTable(tableName="HelperParticipation")
data class HelperParticipation(
        @DynamoDBHashKey var id: String = "",
        var participantId: String = "",
        var date: Date? = null,
        var isMorning: Boolean = true,
        var isMidday: Boolean = true,
        var isEvening: Boolean = true
)

@DynamoDBTable(tableName="session")
data class Session(
        @DynamoDBHashKey var sessionId: String = "",
        var token: String = ""
)