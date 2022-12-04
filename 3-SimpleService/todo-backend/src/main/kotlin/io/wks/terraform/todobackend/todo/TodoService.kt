package io.wks.terraform.todobackend.todo

import com.fasterxml.jackson.annotation.JsonValue
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.validation.annotation.Validated
import java.time.Clock
import java.time.OffsetDateTime

data class TodoRequest(@field:NotBlank val description: String)
data class TodoResponse(@JsonValue val todo: Todo)
data class TodosResponse(val todos: Todos)

class TodoNotFoundException(@Suppress("unused") val id: TodoId) : RuntimeException("Todo with id '$id' not found")

@Service
@Validated
class TodoService(private val todoDao: TodoDao, private val clock: Clock) {

    fun list(): TodosResponse {
        return TodosResponse(Todos(todoDao.findAll().toList()))
    }

    fun createTodo(@Valid request: TodoRequest): TodoResponse {
        return TodoResponse(
            todoDao.save(
                Todo(
                    description = request.description,
                    createdAt = OffsetDateTime.now(clock)
                )
            )
        )
    }

    @Transactional
    fun completeTodo(id: TodoId): Todo {
        return todoDao.findById(id).orElseThrow { TodoNotFoundException(id) }
            .complete(clock)
            .also { todoDao.save(it) }
    }

    fun deleteTodo(id: TodoId) {
        return todoDao.deleteById(id)
    }
}