package io.wks.terraform.todobackend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import java.time.Clock

@Configuration
class ApplicationConfiguration {

    @Bean
    @Profile("!test")
    fun clock(): Clock{
        return Clock.systemUTC()
    }
}