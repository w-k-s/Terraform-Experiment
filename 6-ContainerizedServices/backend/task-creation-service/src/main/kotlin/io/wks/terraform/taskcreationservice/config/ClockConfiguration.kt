package io.wks.terraform.taskcreationservice.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import java.time.Clock

@Configuration
class ClockConfiguration {
    @Bean
    @Profile("!test")
    fun clock() = Clock.systemUTC()
}