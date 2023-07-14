package io.wks.terraform.taskcreationservice.config

import io.wks.terraform.taskcreationservice.persistence.TaskIdReadingConverter
import io.wks.terraform.taskcreationservice.persistence.TaskIdWritingConverter
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.jdbc.core.convert.JdbcCustomConversions
import org.springframework.data.jdbc.repository.config.EnableJdbcRepositories

@Configuration
@EnableJdbcRepositories(basePackages = ["io.wks.terraform.taskcreationservice.persistence"])
class JdbcConfiguration {

    @Bean
    fun jdbcCustomConverters() = JdbcCustomConversions(
        mutableListOf(
            TaskIdReadingConverter(),
            TaskIdWritingConverter(),
        )
    )
}
