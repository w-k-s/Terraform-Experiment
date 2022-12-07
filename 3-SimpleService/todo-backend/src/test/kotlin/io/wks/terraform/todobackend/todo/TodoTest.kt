package io.wks.terraform.todobackend.todo

import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import java.time.Clock
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneOffset

internal class TodoTest {

    val clock = Clock.fixed(
        LocalDateTime.of(
            LocalDate.EPOCH,
            LocalTime.MIDNIGHT
        ).toInstant(ZoneOffset.UTC), ZoneOffset.UTC
    )

    @Test
    fun `GIVEN todo WHEN description is blank THEN illegal argument exception is thrown`() {
        assertThatThrownBy { Todo.create(description = "", clock = clock) }
            .isInstanceOf(IllegalArgumentException::class.java)
            .hasMessage("A description is required")
    }

    @Test
    fun `GIVEN todo WHEN completed THEN completedAt is set`() {
        // GIVEN
        var todo = Todo.create(description = "Read", clock = clock)

        // WHEN
        todo = todo.complete(clock)

        // THEN
        assertThat(todo.description).isEqualTo("Read")
        assertThat(todo.createdAt).isEqualTo(LocalDate.EPOCH.atStartOfDay().atOffset(ZoneOffset.UTC))
        assertThat(todo.completedAt).isEqualTo(LocalDate.EPOCH.atStartOfDay().atOffset(ZoneOffset.UTC))
    }
}