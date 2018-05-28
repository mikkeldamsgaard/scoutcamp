import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import java.net.URI

plugins {
    kotlin("jvm") version "1.2.21"
    java
    id("org.jetbrains.kotlin.kapt") version "1.2.21"
    application
}

repositories {
    mavenCentral()

    maven {
        url = URI("https://s3-us-west-2.amazonaws.com/dynamodb-local/release")
    }

    maven {
        url = URI("https://kotlin.bintray.com/kotlinx")
    }
}

dependencies {
    compile(kotlin("stdlib-jdk8"))
    compile(kotlin("reflect"))
    compile("com.sparkjava", "spark-core", "2.7.1")
    //testCompile("com.github.mlk","assortmentofjunitrules","1.5.36")
    compile("com.amazonaws", "DynamoDBLocal", "1.11.+")
//    compile("com.amazonaws", "aws-java-sdk-cognitoidentit", "1.11.+")
    compile("io.jsonwebtoken", "jjwt", "0.9.0")
    compile("com.fasterxml.jackson.module","jackson-module-kotlin","2.9.4")
    compile("org.slf4j", "slf4j-simple","1.6.1")

}

application {
    mainClassName = "com.cloudpartners.ServerKt"
}