package com.cloudpartners

import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProviderAsyncClientBuilder
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProviderClientBuilder
import com.amazonaws.services.cognitoidp.model.AttributeType
import com.amazonaws.services.cognitoidp.model.ListUsersRequest

data class User (var username: String, var name: String, var email: String)

class CognitoUserAdapter {

    fun listUsers() : List<User> {
        val req = ListUsersRequest().withUserPoolId(userPoolId)
        val result = awsProvider().listUsers(req)
        var mappedUsers =  result.users.map{
            val username = it.username
            val userAttr = it.attributes
            val name = attrGet(userAttr, "name")
            val email = attrGet(userAttr, "email")
            User(username, it.username, it.username)
        }
        return mappedUsers
    }

    private fun attrGet(userAttr: List<AttributeType>, key: String): String? {
        return userAttr.find { it.name == key }?.value
    }

    private val userPoolId get() = Configuration.cognitoPoolId()

    private fun awsProvider() : AWSCognitoIdentityProvider {
        // TODO set up credentials for local testing
        return AWSCognitoIdentityProviderClientBuilder.standard().withRegion(Configuration.cognitoDomain()).build()
    }

}

fun main(args: Array<String>) {
    val userAdapter = CognitoUserAdapter()
    userAdapter.listUsers().forEach{ println( it)}
}
