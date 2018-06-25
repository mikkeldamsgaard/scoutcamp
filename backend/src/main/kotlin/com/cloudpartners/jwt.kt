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

fun getJWTClaims(token: String) : Jws<Claims> {
    return Jwts.parser().parseClaimsJws(token)
}

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

        println("Token is valid")
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
    isJWTValid("{\"id_token\":\"eyJraWQiOiJUUEdBZ05jbllWbENVOUFMdVR0VDByZzNRZjZYK25FaVNnQTFxUmw3WEhnPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiemdXNER2NFRwSXNQQ0owSHU0VC1LQSIsInN1YiI6ImZiZTA4ODRkLWRlMWUtNDFjNy1hNzk2LWVlY2RhYzM3N2Q2ZCIsImF1ZCI6IjF0MTFnYjQ0MnZpcWVxaW9rcjIybHI4b2ZlIiwiY29nbml0bzpncm91cHMiOlsiZXUtd2VzdC0xX1ZOU29yRm1jTV9Hb29nbGUiXSwiaWRlbnRpdGllcyI6W3sidXNlcklkIjoiMTA0MTYyNDY0OTAwMjA4NTY5Njg4IiwicHJvdmlkZXJOYW1lIjoiR29vZ2xlIiwicHJvdmlkZXJUeXBlIjoiR29vZ2xlIiwiaXNzdWVyIjpudWxsLCJwcmltYXJ5IjoidHJ1ZSIsImRhdGVDcmVhdGVkIjoiMTUyNTg1NjA1Mjg5OCJ9XSwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE1Mjc4NDk2MDMsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC5ldS13ZXN0LTEuYW1hem9uYXdzLmNvbVwvZXUtd2VzdC0xX1ZOU29yRm1jTSIsImNvZ25pdG86dXNlcm5hbWUiOiJHb29nbGVfMTA0MTYyNDY0OTAwMjA4NTY5Njg4IiwiZXhwIjoxNTI3ODUzMjAzLCJpYXQiOjE1Mjc4NDk2MDMsImVtYWlsIjoibWlra2VsQGNsb3VkcGFydG5lcnMuY29tIn0.jJOSzAHB-ED5kukyE7qzOBx3yUS1KOCuWpUhkhGArgYu0hz9_sHkKjmVgZYln1RFoNVKglZoQNxHQxCwGC5jINEqG0MpvDpAjY8ch_LW1qhPl_kxipl0fXnTwHZqwjkF0Rz5bwkc3CfckriKNccvhH_7_bYxmi9Vk1x2I_3zVf0JFY3cHr5COAVhJnuM1h0tNU8OYsgSXBxbiEx_ZVRhYOtwIB4Y0t17RIrsh-qTl57TU5ryJKSzq5H2KJuzpS0wZn6BYLoTLjFFrv6sN3zbzUga2loKOW7nxRZC5M7407MRQLWHTeeV2hqCCRtl_dVJjZgTbXT80DZXzbKbncr2gA\",\"access_token\":\"eyJraWQiOiJvQWRuWlwvbjZVY29NUm1mak5VZWlLOEQ4M2dpSll6Vk00UElLMWFwT3c3WT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJmYmUwODg0ZC1kZTFlLTQxYzctYTc5Ni1lZWNkYWMzNzdkNmQiLCJjb2duaXRvOmdyb3VwcyI6WyJldS13ZXN0LTFfVk5Tb3JGbWNNX0dvb2dsZSJdLCJ0b2tlbl91c2UiOiJhY2Nlc3MiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCIsImF1dGhfdGltZSI6MTUyNzg0OTYwMywiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfVk5Tb3JGbWNNIiwiZXhwIjoxNTI3ODUzMjAzLCJpYXQiOjE1Mjc4NDk2MDMsInZlcnNpb24iOjIsImp0aSI6ImQ2NWRhNDYzLWUxZDgtNDg5OC1hYzMxLTg5ZDM5MTI3ZTRkOCIsImNsaWVudF9pZCI6IjF0MTFnYjQ0MnZpcWVxaW9rcjIybHI4b2ZlIiwidXNlcm5hbWUiOiJHb29nbGVfMTA0MTYyNDY0OTAwMjA4NTY5Njg4In0.ID6w_733_IVx68aiRnJ4TrByoNCBcpGw0vUcKdZz8TUDUTFSo5x9uoWTRYb6qaleaRri90lrIq_bCvGDKSOJBT1Khh_RmbQzNU3t4aiF1v5DuutSKRsXeTIp5SkJV66qTubtLN5gHmXrNbqm7y9HxmRWBh6zKExeuQ37PxC137T3ufBd-DIwtYgNq-H1bCN0s1hCXuhYnvKaGadES-911TQJLZdbghH7eyx2SMfCw5kzWzWIDeY-SQYoQko52MOs_e9Ll-uLPedavQjC_tj7yeq7Y65RS9hqzuwamD7GuF4jPUdbhkqxhEYaW3Jc-ZyMVqQH-d_Azyn7JlzOCI2XbA\",\"refresh_token\":\"eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.Jd5_WHiOCsj8_1daldwNhUInd1j5we3jr9mhZ0kElXNPb8aBNCZlO1ny0015CDm-W16xhMLKNmRSJbLVnKXQeR2iQ7X_vExYossGnwKlprRJ4FQzHpjasVvNysD7SS0pSkjNml0dzoFZoTR8NGB85_RQLPD3ZIsiSktSDK4oGn2708QNEWF5ymGrFAOdIG0ncutrAzSBu7bbAhbWYd_Vqf-OmtquldZ4sBBCv4axiKYEG26eMGNi9-PXEOjzrOuz9mzEFhSNGyXDxzzEhE3CeqQiZVb4Y0RRDnFQbY7ocZDdrjupwJacgEVFEZxOhDyLjM7QpwbOrWKeRsFlzQOM7Q.oui1CyYrj2RvRld2.wXJDPUo8rAoUJL9nuP2d681s9n2dYC6IKJm_TgvDadHgQd62xWmsDpY8R5SKLSIJ1VYy7iiuvg-8JGOVcile_L8_vyn_piCGLb3AIG7Veh7g2NPTfC-cIrdtWm1CvBXV6y096Aijf0TXmsQm8aTpfi6cTiNFwG1o7younW4beKsfWB4qjwSOJtpzGy9wJc3XHqYeEnAVSXPXF-CMDlst8wLdz4WgtR06Ob3SWxnLzbhQFfe2WWk2xlRnFv-wxkX6py73_vIyDp61iQ8YQ-08hblXrMgyuq_W7yNUDKSD5F-FyaGwK0jYUgLaClpXDAz8ZwDYNpuuooLPUEZDhYzse5CbWysJmWh7rfhFJOvlyWs1ejuhObNV3fziMmOkN3zk0l_nLRV1FCNQLHmDIN8QsPRCOGZLOW_o6RdcEMQOz7p_riTG4py2lSRTBKF8NkL9N3P-ByU6_YYupvgclUpNTPq-GF65dHPx5wW3PGHvyvs8b36dbpMD7uGf0N1iWFNu_nE8aV-weP2MF8WiVfk7xkUgmk0dZZN9ptxRjATz97LimCIY1q3fJ90TiynWXJOX4kUCEYikpADQZWDyyTuyXmNlR_UFjmgocW1vghgZN-IVW4vHxMNFCzPCPWqG4_Y41WKSnE7eXbg9TA9Svgdws4q-OFjxeFJcWv43pNoBk095rYRoI_MTQZ29yOl7cJ-AqXiWLyNnD2I6H2aRXGjyQIEybgSr1OWqHrqgQ7gtcLRh9MV05hUIUUytN2dzBTVXGhqLtuSeVUCV_-UVqNvOT397fbJgLmEi4ZxmmOz9_Plwbyo1OjTHkTpD6kW0rBdOrybz1zUoZLzthVmogpLAObBEZa1dw3-vjdilghDkaVjVBNmGQNc5873syeRC-ggttnE-zmy41BHPn5dd1wBSxDR-XmL6r9zRB9Y2Ed8XXv3oTlpL-i-e6BW_5dpYjs-B83zvF0tzhmCUec4EvnsLnfmCK7fn52-QS0GiQHHz1r-ceQNavktfmuoNUfxs_pWTzNpe1Rn7FOhFr8DuC-ibp8C8bAaAFv9NHp1kWQD7hiSykVzNr0j0VTcRXQJhRyCYYDaTX1YmKrspKYzS7fDHo_9pxuw8iICF81xCLrpa-LkxBDqIOdNLjgE_Dd2wz4YPl_5NooAUwlknJAoNkOhSmDX3LmgXuyGMEu0tKwpH2drScloWsAZzsSdmWC45N6nL4kvMtdspLg.2AxOeSvKE-RMICwK5Keofw\",\"expires_in\":3600,\"token_type\":\"Bearer\"}")
}

