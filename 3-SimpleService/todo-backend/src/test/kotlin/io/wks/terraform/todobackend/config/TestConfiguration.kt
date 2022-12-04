package io.wks.terraform.todobackend.config

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Profile
import java.time.*

@TestConfiguration
class TestConfiguration {

    @Bean
    @Profile("test")
    fun clock(): Clock {
        return Clock.fixed(
            LocalDateTime.of(LocalDate.EPOCH, LocalTime.MIDNIGHT).toInstant(ZoneOffset.UTC),
            ZoneOffset.UTC
        )
    }
}