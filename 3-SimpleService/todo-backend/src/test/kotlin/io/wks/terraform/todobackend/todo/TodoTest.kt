package io.wks.terraform.todobackend.todo

import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test

internal class TodoTest {

    @Test
    fun `GIVEN todo WHEN description is blank THEN illegal argument exception is thrown`() {
        assertThatThrownBy { Todo(description = "") }
            .isInstanceOf(IllegalArgumentException::class.java)
            .hasMessage("A description is required")
    }

    @Test
    fun `GIVEN todo WHEN completed THEN completedAt is set`() {
        assertThat(Todo(description = "Read").complete().completedAt).isNotNull
    }
}