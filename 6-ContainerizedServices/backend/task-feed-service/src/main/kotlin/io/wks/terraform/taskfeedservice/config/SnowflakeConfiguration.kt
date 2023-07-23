package io.wks.terraform.taskfeedservice.config

import io.wks.snowflake4j.snowflake.Snowflake
import io.wks.snowflake4j.snowflake.SnowflakeFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import java.time.Instant
import java.util.function.Supplier

@Configuration
class SnowflakeConfiguration(@Value("\${snowflake.epoch}") private val epochMillis: Long) {

    @Bean
    @Profile("!test")
    fun snowflakeFactory(): Supplier<Snowflake> =
        SnowflakeFactory.forStandaloneNode(Instant.ofEpochMilli(epochMillis))
}