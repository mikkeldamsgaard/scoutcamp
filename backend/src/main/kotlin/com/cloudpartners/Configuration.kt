package com.cloudpartners

import java.io.FileReader
import java.util.*

object Configuration {
    val properties = Properties()

    init {
        properties.load(FileReader(configFile()))
    }

    fun cognitoClientId(): String = properties.get("cognito_client_id") as String
    fun cognitoRedirectUrl(): String = properties.get("cognito_redirect_url") as String
    fun cognitoDomain(): String = properties.get("cognito_domain") as String
    fun cognitoPoolId(): String = properties.get("cognito_pool_id") as String
    fun cognitoRegion(): String = properties.get("cognito_region") as String

}