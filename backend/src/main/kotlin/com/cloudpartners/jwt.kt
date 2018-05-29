package com.cloudpartners

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import io.jsonwebtoken.*
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.methods.HttpPost
import org.apache.http.entity.ContentType
import org.apache.http.entity.StringEntity
import org.apache.http.impl.client.HttpClients
import java.io.ByteArrayOutputStream
import java.security.Key
import java.security.spec.RSAPublicKeySpec
import java.math.BigInteger
import java.security.KeyFactory
import java.util.*

val httpclient = HttpClients.createDefault()
val jackson = ObjectMapper()

fun isJWTValid(token: String): Boolean {
    try {
        val key_url = "https://cognito-idp.eu-west-1.amazonaws.com/${Configuration.cognitoPoolId()}/.well-known/jwks.json"

        val httpGet = HttpGet(key_url)
        val resp = httpclient.execute(httpGet)
        val baos = ByteArrayOutputStream()

        resp.entity.writeTo(baos)

        val keys_js = baos.toString(Charsets.UTF_8.name())
        resp.close()

        println(keys_js)

        val keys_m: Map<String, List<Map<String, String>>> = jackson.readValue(keys_js)
        println(keys_m["keys"]?.get(0))

        val token_m: Map<String, String> = jackson.readValue(token)
        val id_token = token_m["id_token"] ?: return false

        val x = Jwts.parser().setSigningKeyResolver(
                object : SigningKeyResolverAdapter() {
                    override fun resolveSigningKey(header: JwsHeader<out JwsHeader<*>>?, claims: Claims?): Key {
                        val key_l = keys_m["keys"] ?: throw RuntimeException("Malformed json from AWS keys")
                        val key_id = header?.getKeyId() ?: throw RuntimeException("kid not found in token")
                        val jwk = getKeyById(key_l, key_id)
                        val modulus = BigInteger(1, Base64.getUrlDecoder().decode(jwk.get("n")))
                        val exponent = BigInteger(1, Base64.getUrlDecoder().decode(jwk.get("e")))

                        return KeyFactory.getInstance("RSA").generatePublic(RSAPublicKeySpec(modulus, exponent))

                    }

                    private fun getKeyById(keys_l: List<Map<String, String>>, keyId: String): Map<String, String> {
                        for (entry in keys_l) {
                            if (entry.get("kid").equals(keyId)) return entry
                        }
                        throw RuntimeException("No key found from AWS for kid: " + keyId)
                    }
                }).parseClaimsJws(id_token)

        return true
    } catch (e: Exception) {
        println("Jwt Validation threw exception: "+e.message)
        e.printStackTrace()
    }
    return false
}

fun codeToToken(code: String): String {
    val httpPost = HttpPost("https://${Configuration.cognitoDomain()}/oauth2/token")

    httpPost.entity = StringEntity("grant_type=authorization_code&client_id=${Configuration.cognitoClientId()}&code=$code&redirect_uri=${Configuration.cognitoRedirectUrl()}", ContentType.APPLICATION_FORM_URLENCODED)

    val response = httpclient.execute(httpPost)

    val boas = ByteArrayOutputStream()
    response.entity.writeTo(boas)
    val respBody = boas.toString(Charsets.UTF_8.name())

    response.close()

    return respBody
}

fun main(args: Array<String>) {
    //println(codeToToken("39dfce2c-42bd-4a5c-be7f-6e685d7ac3eb"))
    isJWTValid("{\"id_token\":\"eyJraWQiOiJUUEdBZ05jbllWbENVOUFMdVR0VDByZzNRZjZYK25FaVNnQTFxUmw3WEhnPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiYWhSWERLM1VuME9QT2cwUlUxXzV2USIsInN1YiI6ImZiZTA4ODRkLWRlMWUtNDFjNy1hNzk2LWVlY2RhYzM3N2Q2ZCIsImF1ZCI6IjF0MTFnYjQ0MnZpcWVxaW9rcjIybHI4b2ZlIiwiY29nbml0bzpncm91cHMiOlsiZXUtd2VzdC0xX1ZOU29yRm1jTV9Hb29nbGUiXSwiaWRlbnRpdGllcyI6W3sidXNlcklkIjoiMTA0MTYyNDY0OTAwMjA4NTY5Njg4IiwicHJvdmlkZXJOYW1lIjoiR29vZ2xlIiwicHJvdmlkZXJUeXBlIjoiR29vZ2xlIiwiaXNzdWVyIjpudWxsLCJwcmltYXJ5IjoidHJ1ZSIsImRhdGVDcmVhdGVkIjoiMTUyNTg1NjA1Mjg5OCJ9XSwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE1MjU4NTYxMzAsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC5ldS13ZXN0LTEuYW1hem9uYXdzLmNvbVwvZXUtd2VzdC0xX1ZOU29yRm1jTSIsImNvZ25pdG86dXNlcm5hbWUiOiJHb29nbGVfMTA0MTYyNDY0OTAwMjA4NTY5Njg4IiwiZXhwIjoxNTI1ODU5NzMwLCJpYXQiOjE1MjU4NTYxMzAsImVtYWlsIjoibWlra2VsQGNsb3VkcGFydG5lcnMuY29tIn0.P1ng6OLYoTAEeSaeKv9Qerob21zoZw7ku4m-w_xq7DFIAr8eGiXygG2D4B3iFcm_w-zZtXCD087vJVsVGTtcOHaHLA8dBbxN_nseCC0IE3PSGPFoB9CXpEybkMjaUvbFCrC2a0KwIFVCA2pOZQ_roPLLYpkwonhqWHWnjqaw2_wHun80Qj0eLvcpKwwMXthtrS1GpsfYyaZrY-xCBadDcBfs4Sd2wBoElxMdAIQipkEwGSjwBXBrMyFKHhZKxz3I_gL8kelRkZGhAQxRoU9n-1TC1SelecyStooVVD7NP71TvkguNldUAndy2lowdx-V-DBpHLq1ML_5vjOEwBbPNg\",\"access_token\":\"eyJraWQiOiJvQWRuWlwvbjZVY29NUm1mak5VZWlLOEQ4M2dpSll6Vk00UElLMWFwT3c3WT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJmYmUwODg0ZC1kZTFlLTQxYzctYTc5Ni1lZWNkYWMzNzdkNmQiLCJjb2duaXRvOmdyb3VwcyI6WyJldS13ZXN0LTFfVk5Tb3JGbWNNX0dvb2dsZSJdLCJ0b2tlbl91c2UiOiJhY2Nlc3MiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCIsImF1dGhfdGltZSI6MTUyNTg1NjEzMCwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfVk5Tb3JGbWNNIiwiZXhwIjoxNTI1ODU5NzMwLCJpYXQiOjE1MjU4NTYxMzAsInZlcnNpb24iOjIsImp0aSI6ImU1ZGI1NDFmLTc5NTgtNGY5ZS1iYTk5LWVlNDIxMzM2ZGY3OSIsImNsaWVudF9pZCI6IjF0MTFnYjQ0MnZpcWVxaW9rcjIybHI4b2ZlIiwidXNlcm5hbWUiOiJHb29nbGVfMTA0MTYyNDY0OTAwMjA4NTY5Njg4In0.E36UuV7LEfbQngM-kW1tnhzHLf5PdvBtEmwNOmC1kkQ8RcTuBTdz2Hnpx4jh4tjsCoH_-IGl8MYGQzZt33XnV0Ze0rSF6R7TKY-YUme1GLzcOoDNIPEpIKql_2dbPAw-nKUuagRFOYnVAjbrQtg8E7iAOeqb9z2zPjMvee2xwWLCcVnviZDPFZJw-gS0lkSkfAsB3mTuIEFLFey319dton7732HodcGbZEATrAFXkRZqFR15BW3nlxkGScFzApB-ymOyl3uTdNo3thN90m0drfFZ7Smm9OG-EJNDRsuMu0wSrznS8-BoIjMMKY1B0DTv3PnVZCme2Yy5mWcwKbBc-A\",\"refresh_token\":\"eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.Z3ThSdupG4Nj9yGNcrlDc6PagglIeGJ7XguDXE7LJF6JozooQ2e4kknEk1qf6rcFG_EKj03tAB4i8zQ-4fw6hDis-5DXFA5kWoheEgMGTH9MlMbX1qke5IphT2AqvevnEednIKcOjM9-5DftjXWcjXCaNy4GCXaZ59ysm4SBuUTtSDBi9w0Ox54Uatzhsw9DpDq4DZPKOb8J3cVGTDOi8RpXD6sLwdj0SAceZpZr6RLfCSHV6fG-xhp6KMpSSqXHjnovstF3tI16aZEW2w7y_Wmgn1I1cBwKhhF6SgUC9zJsMqV-P9WOEepVfSbZEWL6NmmKN_NBKQuWkfTs003vXA.j5SyZEsXRUdtLPdR.mOUfUfHi5UwSdU8hWkS73qSnWhZpqx53WUGkn-r2WljZ8TxUH-M87k0TfrTXosj89njIW4BJugluRCmEMkQo_2TN5aRCCtbbqUT9a6N8Wi9Z5kMknmei9Mwg3xMUkbYGn2qJqebuaDjx5n4DEBuKyW1rF3qUpxV5z0ehRaGqyxz6PPLvobyzJDj0cudy5KOXh2JYF0UJuGWnvZ_M_UucM7VJPua0Ugs4xg3OsdRMSGmoZw1O04VCfG20vAEzSYefPi0lFGHGCOO-Q54ACMtIjZbr5IleEiUZS16S1wxlKP0LRQ0AifEy4_z8IJUKezlXwmiTmX-QYvDUBVEBgThiyidWkqnSCywnyr6IR8a0nrFnu_I0iDMc6ZuWHw5WGFKHWAT3ui1WCwCHWeZ_IMxEdfnn8f349pXC1M5vwjaXPAwkytrqP6nme2T8zY2VSuTycwzSIfuC6yhZyUs0XrL6yrYeg637r_sfCzDljazpKPqXBOdAVXcEgb4yugZxNffzbPx78DYlNe8yGiu82xBCUIeznBuVjxsk0diH9VwgwJBTh6BosaY9aDhLg_wDLW3JEYjNean3qyXHyYI7tNVA8ciZOO8TwEQZQB8jXBwGx9c64V5fWxx5czMmrW-HhfYCjzZL5m7c9aIIfeUyqPDfR4Fh2P5M5M59FKzDLOr-VTJEuhVxrdl4LepKu9qiEVRKt6z-RlcDBxjQJ_HnSrQb2Jsh9JqIh8TLEc5TXtPceQkXPa2DVDl_I4ZYDOjBEw9bLyvX_Q04TVevmMa6yL5cOj52SxVU6ZTlIsS8Xw1SJfhp7cT9p4unEgU3JhmJ8QqsrQNuIRCb105MCrFtnGKSDyBa0sHTe7lJnRmL1La3WjQUJG9ymNIFJKw872HdhdspDtRTZxSMGWL60W8rf80SybAvXD_A_Lkyg2uaLwnwuQxjqPdMORUBICNno96nTlkW-s4b8eSuU-wLUuCQgl6pNwOGusoQ2TlUMKPbSbBKPGb-Mc5eF0YIOIaXGg3m_vACewrKBKZqIa6OFdIQwe9JxONyryPSZ7OVU5fVjyUQY78H_Mq_iwR5TzADR2nECylXXARlX9GbIxFHV_NWVW8zvdAbKYPOl0a-it4ySu8RISsNneziBNcqV1LyQQ2ezAhtF0jp13Btzmuzzmnnysg9c7IOUTfXstZnDiBikpM79gKwNmtGjQBEMCKfAL5G06n4q9aUMiimoA.mfNubSZ3INwvYpT6iRxhZA\",\"expires_in\":3600,\"token_type\":\"Bearer\"}")
}

