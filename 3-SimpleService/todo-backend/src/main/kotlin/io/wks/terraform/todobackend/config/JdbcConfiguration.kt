package io.wks.terraform.todobackend.config

import io.wks.terraform.todobackend.todo.LongToTodoIdConverter
import io.wks.terraform.todobackend.todo.TodoIdToLongConverter
import org.springframework.context.annotation.Configuration
import org.springframework.data.jdbc.repository.config.AbstractJdbcConfiguration


@Configuration
class JdbcConfiguration : AbstractJdbcConfiguration() {

    override fun userConverters(): MutableList<*> {
        return mutableListOf(
            TodoIdToLongConverter(),
            LongToTodoIdConverter(),
        )
    }
}